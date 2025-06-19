# 🎮 Coin Collector Game (x86 Assembly)

A classic coin collection game developed in **x86 Assembly Language** using **DOS interrupts**, demonstrating low-level programming concepts like real-time input handling, screen drawing, and random number generation.

## 🕹️ Gameplay

- **Single-Player Mode**: Control character "A" to collect coins  
- **Two-Player Mode**: Characters "A" and "B" compete to collect more coins  
- **Scoring System**: Score increases on coin collection  
- **Game Over**: Triggered by collisions with borders or between players  
- **Winner Announcement**: Highest score wins

## 🧠 Technical Features

- Input handling via `INT 16h` (keyboard)  
- Random coin placement using system time (`INT 1Ah`)  
- Screen manipulation with `INT 10h` (cursor positioning)  
- Real-time movement and score updates  
- Code structured using procedures and registers

## 🧰 Tools & Requirements

- **Assembler**: TASM or MASM  
- **Emulator**: DOSBox or any DOS emulator  
- **Platform**: MS-DOS (or compatible environment)

## 🔧 How to Run

1. Assemble the code using TASM/MASM:
   ```bash
   tasm coincollector.asm
   tlink coincollector.obj
   ```
2. Run the `.exe` in DOSBox:
   ```bash
   coincollector.exe
   ```

## 🚀 Future Enhancements

- Add sound effects (using `INT 10h`)  
- High score system with file storage  
- Difficulty levels (speed & obstacles)  
- Improved visuals using extended ASCII

## 📚 Learning Outcomes

This project demonstrates:  
- Low-level hardware interaction  
- Efficient use of registers and memory  
- Real-time input and screen management  
- Fundamental game loop logic in Assembly
