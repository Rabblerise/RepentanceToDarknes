## Imitation of Human Behavior in the World of Darkness and Fantasy

This project showcases the intersection of creativity and technology, where artificial intelligence (AI) serves as a key component in shaping the future of the gaming industry. The project not only demonstrates technical prowess but also realizes ambitious ideas aimed at creating an immersive gaming experience.
![изображение](https://github.com/user-attachments/assets/3a04734c-246f-44a6-8ea6-d7b333821f4a)


## The following key aspects of the project will be discussed:

## 1. Game Development on Godot Engine:
- The project explored the capabilities of the Godot engine, focusing on the creation of an AI companion and its interaction with the game world.
- The AI companion was implemented using the **CharacterBody2D** class, with its behavior scripted in GDScript.
- The companion follows the player and performs actions within a specified area, enhancing the gameplay experience.

## 2. Example of AI Companion Implementation:
```gdscript

class_name Player
extends CharacterBody2D

var input_actions := ["Jump", "goRight", "goLeft"]
var state: FSM_State = FSM_State_Idle.new(self)

# Player movement and jumping logic...
```
![изображение](https://github.com/user-attachments/assets/25a1fe34-0e28-4ae0-911c-4e8838f420ed)

## 3. Neural Networks and ONNX Models:
- The integration of ONNX models into the Godot engine allowed for the inclusion of advanced AI algorithms.
- Libraries such as Microsoft.ML.OnnxRuntime and Microsoft.ML.OnnxRuntime.DirectML were used to facilitate this integration.
- The project utilized pre-trained models, with potential for future development involving custom training of AI systems.

## 4. Loss Functions and Optimizers:
```python

criterion_seq2seq = nn.CrossEntropyLoss(ignore_index=0)
optimizer_seq2seq = optim.Adam(seq2seq_model.parameters(), lr=0.001)

```

## 5. Import and Usage of ONNX Model:
```python

import onnxruntime as ort
ort_session = ort.InferenceSession("seq2seq_model.onnx")
outputs = ort_session.run(None, {"src": src_dummy_input})

```
## 6. Integration and Testing:
- The project went through several testing phases, including training a Seq2Seq model and a classifier for dialogue interaction.
- Inference results indicate the successful integration of models and their functionality within the game process.

## 7. UI Development in Godot:
- The project also delved into creating a user interface (UI) that interacts seamlessly with the AI system.
- The UI was built using Godot’s built-in tools, featuring elements like buttons, labels, and panels for an intuitive user experience.

## 8.Future Directions:
- This project lays the foundation for future exploration into more complex AI systems and enhanced gameplay mechanics.
- Potential areas for further development include refining the AI's decision-making processes and expanding the interactive elements of the game world.
![изображение](https://github.com/user-attachments/assets/03c94648-da90-4aab-b0b3-c11cf47c8f98)

