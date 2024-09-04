using Godot;
using System;
using System.Collections.Generic;
using System.IO;
using Newtonsoft.Json;
using Microsoft.ML.OnnxRuntime;
using Microsoft.ML.OnnxRuntime.Tensors;
using System.Linq;
using System.Text;

public partial class ChatBot : Node
{
	private InferenceSession seq2seqSession;
	private InferenceSession classifierSession;
	private Dictionary<string, int> vocab;
	private string[] labelEncoder;
	private int maxSeqLength = 30; // Assuming a max sequence length
	
	public override void _Ready()
	{
		Init();
	}
	
	public void Init(){
		GD.Print("Loading seq2seq model...");
		seq2seqSession = new InferenceSession("Objects/Chaos/Scripts/Models/seq2seq_model.onnx");
		GD.Print("Seq2seq model loaded successfully.");

		GD.Print("Loading classifier model...");
		classifierSession = new InferenceSession("Objects/Chaos/Scripts/Models/classifier_model.onnx");
		GD.Print("Classifier model loaded successfully.");

		vocab = LoadVocab("Objects/Chaos/Scripts/Models/vocab.json");
		labelEncoder = LoadLabelEncoder("Objects/Chaos/Scripts/Models/label_encoder.json");

		if (vocab == null)
		{
			GD.PrintErr("Failed to load vocab!");
		}
		else
		{
			GD.Print($"Loaded vocab with {vocab.Count} entries.");
		}

		if (labelEncoder == null)
		{
			GD.PrintErr("Failed to load label encoder!");
		}
		else
		{
			GD.Print($"Loaded label encoder with {labelEncoder.Length} labels.");
		}
	}

	private Dictionary<string, int> LoadVocab(string path)
	{
		try
		{
			using (StreamReader r = new StreamReader(path, Encoding.UTF8))
			{
				string json = r.ReadToEnd();
				return JsonConvert.DeserializeObject<Dictionary<string, int>>(json);
			}
		}
		catch (Exception ex)
		{
			GD.PrintErr($"Error loading vocab: {ex.Message}");
			return null;
		}
	}

	private string[] LoadLabelEncoder(string path)
	{
		try
		{
			using (StreamReader r = new StreamReader(path, Encoding.UTF8))
			{
				string json = r.ReadToEnd();
				return JsonConvert.DeserializeObject<string[]>(json);
			}
		}
		catch (Exception ex)
		{
			GD.PrintErr($"Error loading label encoder: {ex.Message}");
			return null;
		}
	}

	private int[] Encode(string text, Dictionary<string, int> vocab)
	{
		if (text == null)
		{
			GD.PrintErr("Input text is null!");
			return Array.Empty<int>();
		}

		if (vocab == null)
		{
			GD.PrintErr("Vocab is null!");
			return Array.Empty<int>();
		}

		var words = text.Split(' ');
		var encoded = new List<int>();
		foreach (var word in words)
		{
			if (vocab.ContainsKey(word))
			{
				encoded.Add(vocab[word]);
			}
		}
		return encoded.ToArray();
	}
	private string DecodeUnicodeString(string encodedString)
	{
		return System.Text.RegularExpressions.Regex.Unescape(encodedString);
	}

	public string GetBotResponse(string userMessage)
	{
		Init();
		string response = DecodeSequence(userMessage);
		string responseType = ClassifyResponseType(userMessage);
		return $"Ответ бота: {response}\nХарактер ответа: {responseType}";
	}

	private string DecodeSequence(string inputSeq)
	{
		int[] inputEncoded = Encode(inputSeq, vocab);

		if (inputEncoded == null || inputEncoded.Length == 0)
		{
			return "Ошибка: пустой или некорректный ввод.";
		}

		var inputTensor = new DenseTensor<long>(new[] { 1, maxSeqLength });
		for (int i = 0; i < inputEncoded.Length; i++)
		{
			inputTensor[0, i] = inputEncoded[i];
		}

		var hiddenTensor = new DenseTensor<float>(new[] { 1, 1, 512 });
		var cellTensor = new DenseTensor<float>(new[] { 1, 1, 512 });
		var teacherForcingTensor = new DenseTensor<long>(new[] { 1 });

		var inputs = new List<NamedOnnxValue>
		{
			NamedOnnxValue.CreateFromTensor("src", inputTensor),
			NamedOnnxValue.CreateFromTensor("trg", new DenseTensor<long>(new[] { 1, maxSeqLength })),
			NamedOnnxValue.CreateFromTensor("hidden", hiddenTensor),
			NamedOnnxValue.CreateFromTensor("cell", cellTensor)
		};

		using (var results = seq2seqSession.Run(inputs))
		{
			var output = results.First().AsTensor<float>();
			var response = new List<string>();

			for (int i = 0; i < output.Dimensions[1]; i++)
			{
				var slice = new float[output.Dimensions[2]];
				for (int j = 0; j < output.Dimensions[2]; j++)
				{
					slice[j] = output[0, i, j];
				}
				int topIndex = Array.IndexOf(slice, slice.Max());
				if (topIndex == vocab["<end>"])
					break;
				response.Add(vocab.FirstOrDefault(x => x.Value == topIndex).Key);
			}

			return string.Join(" ", response);
		}
	}

	private string ClassifyResponseType(string inputSeq)
	{
		int[] inputEncoded = Encode(inputSeq, vocab);

		if (inputEncoded == null || inputEncoded.Length == 0)
		{
			return "Ошибка: пустой или некорректный ввод.";
		}

		var inputTensor = new DenseTensor<long>(new[] { 1, maxSeqLength });
		for (int i = 0; i < inputEncoded.Length; i++)
		{
			inputTensor[0, i] = inputEncoded[i];
		}

		var inputs = new List<NamedOnnxValue>
		{
			NamedOnnxValue.CreateFromTensor("input", inputTensor)
		};

		using (var results = classifierSession.Run(inputs))
		{
			var output = results.First().AsTensor<float>();
			var outputArray = output.ToArray();
			int topIndex = Array.IndexOf(outputArray, outputArray.Max());
			return labelEncoder[topIndex];
		}
	}
}
