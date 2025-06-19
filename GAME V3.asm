org 100h

; ================= DATA SECTION =================
.data
    ; Game display
    C_DISPLAY   db "      ___  ___              ___  ____              ____  ___ _____  ____   ___       ",0dh,0ah
                db "     |    |   | | |\  |    |    |    | |    |     |     |      |   |    | |___|      ",0dh,0ah
                db "     |    |   | | | \ |    |    |    | |    |     |---- |      |   |    | | \        ",0dh,0ah
                db "     |___ |___| | |  \|    |___ |____| |___ |____ |____ |___   |   |____| |  \       $"
    
    ; Game variables
    SCORE       db 0
    SCORE2      db 0
    N           db "ENTER NAME: $"
    P1          db 20 dup('$')      ; Player 1 name
    P2          db 20 dup('$')      ; Player 2 name
    PLAY1       db " PLAYER:1 $"
    PLAY2       db " PLAYER:2 $"
    VARB        db "B$"
    XPOS        db 20             ; X position of player B
    YPOS        db 12             ; Y position of player B
    VARA        db "A$"
    XPOS2       db 30             ; X position of player A
    YPOS2       db 12             ; Y position of player A
    XCOINPOS    db 20             ; Coin X position
    YCOINPOS    db 10             ; Coin Y position
    INPUT_CHAR  db ?
    
    ; Messages
    WIN_MSG     db "* * * * * * WINNER * * * * * *$"
    TIE_MSG     db "BOTH PLAYERS HAVE SAME SCORE.$"
    MSG_PLAYERS db "1 PLAYER OR 2 PLAYERS? (1/2)$"
    GAME_TITLE  db "**** COIN COLLECTOR **** $"
    PLAY_AGAIN_MSG db "PLAY AGAIN? (1=YES, OTHER=NO)$"
    KEYS_A      db "PLAYER A: W-UP Z-DOWN A-LEFT D-RIGHT$"
    KEYS_B      db "PLAYER B: I-UP M-DOWN J-LEFT L-RIGHT$"
    GAMEOVER_MSG db "GAME OVER!$"

    ; Input buffers
    P1_BUFFER   db 20, 0, 20 dup('$')
    P2_BUFFER   db 20, 0, 20 dup('$')

; ================= CODE SECTION =================
.code
start:
    call CLEAR_SCREEN
    call main
    mov ax, 4C00h    ; Exit program
    int 21h

; ================= MAIN PROCEDURE =================
main PROC
    tryagain:
        mov SCORE, 0
        mov SCORE2, 0
        
        call CLEAR_SCREEN
        
        ; Display game title
        mov dx, offset C_DISPLAY
        mov ah, 9
        int 21h
        
        ; Ask for number of players
        mov dh, 10     ; Row
        mov dl, 30     ; Column
        call SET_CURSOR
        
        mov dx, offset MSG_PLAYERS
        mov ah, 9
        int 21h
        
        ; Get player count (1 or 2)
        mov ah, 1
        int 21h
        sub al, '0'
        cmp al, 2
        je PLAYER_2
        
        ; ============ SINGLE PLAYER MODE ============
        mov XPOS2, 30
        mov YPOS2, 12
        
        ; Clear screen and show title
        call CLEAR_SCREEN
        mov dx, offset C_DISPLAY
        mov ah, 9
        int 21h
        
        ; Get player name
        call Player_name_single
        
        ; Set up game screen
        call CLEAR_SCREEN
        call NEW_LINE
        
        mov dx, offset GAME_TITLE
        mov ah, 9
        int 21h
        
        ; Draw game border
        call Draw_Border
        
        ; Draw player info
        call Draw_Score_single
        
        ; Draw player
        call DrawPlayer_single
        
        ; Create first coin
        call CreateRandomCoin
        
        ; Main game loop
        mov cx, 0FFFFh
    gameLoop1:
        push cx
        
        ; Display score
        call DisplayScore_single
        
        ; Get input
        call GetInput_single
        
        ; Check game over
        call CheckGameOver_single
        cmp al, 1
        je GAME_OVER1_1
        
        ; Check coin collection
        call CheckCoinCollection_single
        cmp al, 1
        jne NOT_COLLECTING1
        
        inc SCORE
        call CreateRandomCoin
        
    NOT_COLLECTING1:
        pop cx
        loop gameLoop1
        
    GAME_OVER1_1:
        call GameOverScreen_single
        jmp AskPlayAgain
        
    ; ============ TWO PLAYER MODE ============
    PLAYER_2:
        mov SCORE2, 0
        mov XPOS, 20
        mov YPOS, 12
        mov XPOS2, 30
        mov YPOS2, 12
        
        ; Clear screen and show title
        call CLEAR_SCREEN
        mov dx, offset C_DISPLAY
        mov ah, 9
        int 21h
        
        ; Get player names
        call Player_name_multi
        
        ; Set up game screen
        call CLEAR_SCREEN
        call NEW_LINE
        
        mov dx, offset GAME_TITLE
        mov ah, 9
        int 21h
        
        ; Draw game border
        call Draw_Border
        
        ; Draw player info
        call Draw_Score_multi
        
        ; Draw players
        call DrawPlayers_multi
        
        ; Create first coin
        call CreateRandomCoin
        
        ; Main game loop
        mov cx, 0FFFFh
    gameLoop:
        push cx
        
        ; Display scores
        call DisplayScores_multi
        
        ; Get input
        call GetInput_multi
        
        ; Check collisions and game over
        call CheckCollisions
        cmp al, 1
        je GAME_OVER1
        
        ; Check coin collection
        call CheckCoinCollection_multi
        cmp al, 1
        jne NOT_COLLECTING
        
        ; Determine which player collected the coin
        mov al, XPOS
        cmp al, XCOINPOS
        jne player_A_collected
        mov al, YPOS
        cmp al, YCOINPOS
        jne player_A_collected
        
        ; Player B collected coin
        inc SCORE2
        jmp create_new_coin
        
    player_A_collected:
        ; Player A collected coin
        inc SCORE
        
    create_new_coin:
        call CreateRandomCoin
        
    NOT_COLLECTING:
        pop cx
        loop gameLoop
        
    GAME_OVER1:
        call GameOverScreen_multi
    
    AskPlayAgain:
        ; Ask if player wants to play again
        mov dh, 15
        mov dl, 25
        call SET_CURSOR
        
        mov dx, offset PLAY_AGAIN_MSG
        mov ah, 9
        int 21h
        
        ; Get response
        mov ah, 1
        int 21h
        cmp al, '1'
        je tryagain
        
    exit_game:
        ret
main ENDP

; ================= PLAYER NAME PROCEDURES =================
Player_name_single PROC
    ; Player 1 name input
    mov dh, 12     ; Row
    mov dl, 30     ; Column
    call SET_CURSOR
    
    mov dx, offset PLAY1
    mov ah, 9
    int 21h
    
    mov dh, 13     ; Row
    mov dl, 30     ; Column
    call SET_CURSOR
    
    mov dx, offset N
    mov ah, 9
    int 21h
    
    ; Read player name
    mov dx, offset P1_BUFFER
    mov ah, 0Ah
    int 21h
    
    ; Copy name to P1
    mov si, offset P1_BUFFER + 2
    mov di, offset P1
    mov cl, [P1_BUFFER + 1]
    mov ch, 0
    rep movsb
    mov byte ptr [di], '$'
    
    ret
Player_name_single ENDP

Player_name_multi PROC
    ; Player 1 name input
    mov dh, 10     ; Row
    mov dl, 30     ; Column
    call SET_CURSOR
    
    mov dx, offset PLAY1
    mov ah, 9
    int 21h
    
    mov dh, 11     ; Row
    mov dl, 30     ; Column
    call SET_CURSOR
    
    mov dx, offset N
    mov ah, 9
    int 21h
    
    ; Read player 1 name
    mov dx, offset P1_BUFFER
    mov ah, 0Ah
    int 21h
    
    ; Copy name to P1
    mov si, offset P1_BUFFER + 2
    mov di, offset P1
    mov cl, [P1_BUFFER + 1]
    mov ch, 0
    rep movsb
    mov byte ptr [di], '$'
    
    ; Player 2 name input
    mov dh, 13     ; Row
    mov dl, 30     ; Column
    call SET_CURSOR
    
    mov dx, offset PLAY2
    mov ah, 9
    int 21h
    
    mov dh, 14     ; Row
    mov dl, 30     ; Column
    call SET_CURSOR
    
    mov dx, offset N
    mov ah, 9
    int 21h
    
    ; Read player 2 name
    mov dx, offset P2_BUFFER
    mov ah, 0Ah
    int 21h
    
    ; Copy name to P2
    mov si, offset P2_BUFFER + 2
    mov di, offset P2
    mov cl, [P2_BUFFER + 1]
    mov ch, 0
    rep movsb
    mov byte ptr [di], '$'
    
    ret
Player_name_multi ENDP

; ================= GAME PROCEDURES =================
Draw_Border PROC
    ; Draw top border (from column 15 to 65, row 5)
    mov dh, 5       ; Row
    mov dl, 15      ; Start column
    call SET_CURSOR
    
    mov cx, 51      ; Number of characters (65-15+1)
draw_top:
    mov al, '*'     ; Border character
    call WRITE_CHAR
    inc dl          ; Move cursor right
    loop draw_top
    
    ; Draw bottom border (from column 15 to 65, row 20)
    mov dh, 20      ; Row
    mov dl, 15      ; Start column
    call SET_CURSOR
    
    mov cx, 51      ; Number of characters
draw_bottom:
    mov al, '*'
    call WRITE_CHAR
    inc dl
    loop draw_bottom
    
    ; Draw left and right borders (from row 6 to 19)
    mov bl, 6       ; Starting row
    mov cx, 14      ; Number of rows (19-6+1)
    
draw_sides:
    ; Left border (column 15)
    mov dh, bl
    mov dl, 15
    call SET_CURSOR
    mov al, '*'
    call WRITE_CHAR
    
    ; Right border (column 65)
    mov dh, bl
    mov dl, 65
    call SET_CURSOR
    mov al, '*'
    call WRITE_CHAR
    
    inc bl
    loop draw_sides
    
    ret
Draw_Border ENDP

Draw_Score_single PROC
    ; Draw player 1 score (above border)
    mov dh, 2      ; Row
    mov dl, 15     ; Column
    call SET_CURSOR
    
    mov dx, offset PLAY1
    mov ah, 9
    int 21h
    
    mov dh, 3      ; Row
    mov dl, 15     ; Column
    call SET_CURSOR
    
    mov dx, offset P1
    mov ah, 9
    int 21h
    
    mov dh, 4      ; Row
    mov dl, 15     ; Column
    call SET_CURSOR
    
    mov dx, offset VARA
    mov ah, 9
    int 21h
    
    mov al, ':'
    call WRITE_CHAR
    
    mov al, ' '
    call WRITE_CHAR
    
    mov al, SCORE
    add al, '0'
    call WRITE_CHAR
    
    ; Draw controls (below border)
    mov dh, 22     ; Row
    mov dl, 15     ; Column
    call SET_CURSOR
    
    mov dx, offset KEYS_A
    mov ah, 9
    int 21h
    
    ret
Draw_Score_single ENDP

Draw_Score_multi PROC
    ; Draw player 1 score (left side above border)
    mov dh, 2      ; Row
    mov dl, 15     ; Column
    call SET_CURSOR
    
    mov dx, offset PLAY1
    mov ah, 9
    int 21h
    
    mov dh, 3      ; Row
    mov dl, 15     ; Column
    call SET_CURSOR
    
    mov dx, offset P1
    mov ah, 9
    int 21h
    
    mov dh, 4      ; Row
    mov dl, 15     ; Column
    call SET_CURSOR
    
    mov dx, offset VARA
    mov ah, 9
    int 21h
    
    mov al, ':'
    call WRITE_CHAR
    
    mov al, ' '
    call WRITE_CHAR
    
    mov al, SCORE
    add al, '0'
    call WRITE_CHAR
    
    ; Draw player 2 score (right side above border)
    mov dh, 2      ; Row
    mov dl, 45     ; Column
    call SET_CURSOR
    
    mov dx, offset PLAY2
    mov ah, 9
    int 21h
    
    mov dh, 3      ; Row
    mov dl, 45     ; Column
    call SET_CURSOR
    
    mov dx, offset P2
    mov ah, 9
    int 21h
    
    mov dh, 4      ; Row
    mov dl, 45     ; Column
    call SET_CURSOR
    
    mov dx, offset VARB
    mov ah, 9
    int 21h
    
    mov al, ':'
    call WRITE_CHAR
    
    mov al, ' '
    call WRITE_CHAR
    
    mov al, SCORE2
    add al, '0'
    call WRITE_CHAR
    
    ; Draw controls (below border)
    mov dh, 22     ; Row
    mov dl, 15     ; Column
    call SET_CURSOR
    
    mov dx, offset KEYS_A
    mov ah, 9
    int 21h
    
    mov dh, 23     ; Row
    mov dl, 15     ; Column
    call SET_CURSOR
    
    mov dx, offset KEYS_B
    mov ah, 9
    int 21h
    
    ret
Draw_Score_multi ENDP

DrawPlayer_single PROC
    mov dh, YPOS2
    mov dl, XPOS2
    call SET_CURSOR
    
    mov dx, offset VARA
    mov ah, 9
    int 21h
    ret
DrawPlayer_single ENDP

DrawPlayers_multi PROC
    ; Draw player A
    mov dh, YPOS2
    mov dl, XPOS2
    call SET_CURSOR
    
    mov dx, offset VARA
    mov ah, 9
    int 21h
    
    ; Draw player B
    mov dh, YPOS
    mov dl, XPOS
    call SET_CURSOR
    
    mov dx, offset VARB
    mov ah, 9
    int 21h
    ret
DrawPlayers_multi ENDP

DisplayScore_single PROC
    mov dh, 4      ; Row
    mov dl, 22     ; Column (after "A: ")
    call SET_CURSOR
    
    mov al, SCORE
    add al, '0'
    call WRITE_CHAR
    ret
DisplayScore_single ENDP

DisplayScores_multi PROC
    ; Player 1 score
    mov dh, 4      ; Row
    mov dl, 22     ; Column (after "A: ")
    call SET_CURSOR
    
    mov al, SCORE
    add al, '0'
    call WRITE_CHAR
    
    ; Player 2 score
    mov dh, 4      ; Row
    mov dl, 52     ; Column (after "B: ")
    call SET_CURSOR
    
    mov al, SCORE2
    add al, '0'
    call WRITE_CHAR
    ret
DisplayScores_multi ENDP

GetInput_single PROC
    ; Check if key pressed
    mov ah, 1
    int 16h
    jz no_input
    
    ; Get the key
    mov ah, 0
    int 16h
    mov INPUT_CHAR, al
    
    ; Process input
    cmp INPUT_CHAR, 'w'    ; Up
    je move_up_A
    cmp INPUT_CHAR, 'z'    ; Down
    je move_down_A
    cmp INPUT_CHAR, 'a'    ; Left
    je move_left_A
    cmp INPUT_CHAR, 'd'    ; Right
    je move_right_A
    jmp no_input
    
move_up_A:
    dec YPOS2
    jmp input_done
move_down_A:
    inc YPOS2
    jmp input_done
move_left_A:
    dec XPOS2
    jmp input_done
move_right_A:
    inc XPOS2
    
input_done:
    call DrawPlayer_single
no_input:
    ret
GetInput_single ENDP

GetInput_multi PROC
    ; Check if key pressed
    mov ah, 1
    int 16h
    jz no_input_multi
    
    ; Get the key
    mov ah, 0
    int 16h
    mov INPUT_CHAR, al
    
    ; Process input
    cmp INPUT_CHAR, 'w'    ; Player A Up
    je move_up_A_multi
    cmp INPUT_CHAR, 'z'    ; Player A Down
    je move_down_A_multi
    cmp INPUT_CHAR, 'a'    ; Player A Left
    je move_left_A_multi
    cmp INPUT_CHAR, 'd'    ; Player A Right
    je move_right_A_multi
    cmp INPUT_CHAR, 'i'    ; Player B Up
    je move_up_B_multi
    cmp INPUT_CHAR, 'm'    ; Player B Down
    je move_down_B_multi
    cmp INPUT_CHAR, 'j'    ; Player B Left
    je move_left_B_multi
    cmp INPUT_CHAR, 'l'    ; Player B Right
    je move_right_B_multi
    jmp no_input_multi
    
move_up_A_multi:
    dec YPOS2
    jmp input_done_multi
move_down_A_multi:
    inc YPOS2
    jmp input_done_multi
move_left_A_multi:
    dec XPOS2
    jmp input_done_multi
move_right_A_multi:
    inc XPOS2
    jmp input_done_multi
move_up_B_multi:
    dec YPOS
    jmp input_done_multi
move_down_B_multi:
    inc YPOS
    jmp input_done_multi
move_left_B_multi:
    dec XPOS
    jmp input_done_multi
move_right_B_multi:
    inc XPOS
    
input_done_multi:
    call DrawPlayers_multi
no_input_multi:
    ret
GetInput_multi ENDP

CheckGameOver_single PROC
    ; Check if player hit border
    cmp XPOS2, 15    ; Left border
    jle game_over
    cmp XPOS2, 65    ; Right border
    jge game_over
    cmp YPOS2, 5     ; Top border
    jle game_over
    cmp YPOS2, 20    ; Bottom border
    jge game_over
    
    mov al, 0
    ret
    
game_over:
    mov al, 1
    ret
CheckGameOver_single ENDP

CheckCollisions PROC
    ; Check if players collided
    mov al, XPOS
    cmp al, XPOS2
    jne no_collision
    mov al, YPOS
    cmp al, YPOS2
    jne no_collision
    
    ; Players collided
    mov al, 1
    ret
    
no_collision:
    ; Check if player B hit border
    cmp XPOS, 15
    jle game_over_multi
    cmp XPOS, 65
    jge game_over_multi
    cmp YPOS, 5
    jle game_over_multi
    cmp YPOS, 20
    jge game_over_multi
    
    ; Check if player A hit border
    cmp XPOS2, 15
    jle game_over_multi
    cmp XPOS2, 65
    jge game_over_multi
    cmp YPOS2, 5
    jle game_over_multi
    cmp YPOS2, 20
    jge game_over_multi
    
    mov al, 0
    ret
    
game_over_multi:
    mov al, 1
    ret
CheckCollisions ENDP

CheckCoinCollection_single PROC
    ; Check if player collected coin
    mov al, XPOS2
    cmp al, XCOINPOS
    jne no_collect
    mov al, YPOS2
    cmp al, YCOINPOS
    jne no_collect
    
    ; Coin collected
    mov al, 1
    ret
    
no_collect:
    mov al, 0
    ret
CheckCoinCollection_single ENDP

CheckCoinCollection_multi PROC
    ; Check if player A collected coin
    mov al, XPOS2
    cmp al, XCOINPOS
    jne check_player_B
    mov al, YPOS2
    cmp al, YCOINPOS
    jne check_player_B
    
    ; Player A collected coin
    mov al, 1
    ret
    
check_player_B:
    ; Check if player B collected coin
    mov al, XPOS
    cmp al, XCOINPOS
    jne no_collect_multi
    mov al, YPOS
    cmp al, YCOINPOS
    jne no_collect_multi
    
    ; Player B collected coin
    mov al, 1
    ret
    
no_collect_multi:
    mov al, 0
    ret
CheckCoinCollection_multi ENDP

CreateRandomCoin PROC
    ; Generate random X position (16-64)
    mov ah, 0
    int 1Ah        ; Get system time
    mov ax, dx
    xor dx, dx
    mov cx, 49     ; 64-16+1 = 49 possible positions
    div cx         
    add dl, 16     ; Make it 16-64
    mov XCOINPOS, dl
    
    ; Generate random Y position (6-19)
    mov ah, 0
    int 1Ah        ; Get system time again
    mov ax, dx
    xor dx, dx
    mov cx, 14     ; 19-6+1 = 14 possible positions
    div cx         
    add dl, 6      ; Make it 6-19
    mov YCOINPOS, dl
    
    ; Draw the coin
    mov dh, YCOINPOS
    mov dl, XCOINPOS
    call SET_CURSOR
    mov al, 'O'
    call WRITE_CHAR
    
    ret
CreateRandomCoin ENDP

GameOverScreen_single PROC
    call CLEAR_SCREEN
    
    ; Display game over message
    mov dh, 10     ; Row
    mov dl, 30     ; Column
    call SET_CURSOR
    
    mov dx, offset GAMEOVER_MSG
    mov ah, 9
    int 21h
    
    ; Display player info
    mov dh, 12     ; Row
    mov dl, 30     ; Column
    call SET_CURSOR
    
    mov dx, offset PLAY1
    mov ah, 9
    int 21h
    
    mov dh, 13     ; Row
    mov dl, 30     ; Column
    call SET_CURSOR
    
    mov dx, offset P1
    mov ah, 9
    int 21h
    
    ; Display score
    mov dh, 14     ; Row
    mov dl, 30     ; Column
    call SET_CURSOR
    
    mov dx, offset VARA
    mov ah, 9
    int 21h
    
    mov al, ':'
    call WRITE_CHAR
    
    mov al, ' '
    call WRITE_CHAR
    
    mov al, SCORE
    add al, '0'
    call WRITE_CHAR
    
    ret
GameOverScreen_single ENDP

GameOverScreen_multi PROC
    call CLEAR_SCREEN
    
    ; Display game over message
    mov dh, 10     ; Row
    mov dl, 30     ; Column
    call SET_CURSOR
    
    mov dx, offset GAMEOVER_MSG
    mov ah, 9
    int 21h
    
    ; Display winner
    mov al, SCORE
    cmp al, SCORE2
    jg player1_wins
    jl player2_wins
    
    ; Tie game
    mov dh, 12     ; Row
    mov dl, 30     ; Column
    call SET_CURSOR
    
    mov dx, offset TIE_MSG
    mov ah, 9
    int 21h
    jmp display_scores
    
player1_wins:
    mov dh, 12     ; Row
    mov dl, 30     ; Column
    call SET_CURSOR
    
    mov dx, offset WIN_MSG
    mov ah, 9
    int 21h
    
    mov dh, 13     ; Row
    mov dl, 30     ; Column
    call SET_CURSOR
    
    mov dx, offset P1
    mov ah, 9
    int 21h
    jmp display_scores
    
player2_wins:
    mov dh, 12     ; Row
    mov dl, 30     ; Column
    call SET_CURSOR
    
    mov dx, offset WIN_MSG
    mov ah, 9
    int 21h
    
    mov dh, 13     ; Row
    mov dl, 30     ; Column
    call SET_CURSOR
    
    mov dx, offset P2
    mov ah, 9
    int 21h
    
display_scores:
    ; Display player 1 score
    mov dh, 15     ; Row
    mov dl, 30     ; Column
    call SET_CURSOR
    
    mov dx, offset PLAY1
    mov ah, 9
    int 21h
    
    mov dh, 16     ; Row
    mov dl, 30     ; Column
    call SET_CURSOR
    
    mov dx, offset P1
    mov ah, 9
    int 21h
    
    mov dh, 17     ; Row
    mov dl, 30     ; Column
    call SET_CURSOR
    
    mov al, ':'
    call WRITE_CHAR
    
    mov al, ' '
    call WRITE_CHAR
    
    mov al, SCORE
    add al, '0'
    call WRITE_CHAR
    
    ; Display player 2 score
    mov dh, 15     ; Row
    mov dl, 50     ; Column
    call SET_CURSOR
    
    mov dx, offset PLAY2
    mov ah, 9
    int 21h
    
    mov dh, 16     ; Row
    mov dl, 50     ; Column
    call SET_CURSOR
    
    mov dx, offset P2
    mov ah, 9
    int 21h
    
    mov dh, 17     ; Row
    mov dl, 50     ; Column
    call SET_CURSOR
    
    mov al, ':'
    call WRITE_CHAR
    
    mov al, ' '
    call WRITE_CHAR
    
    mov al, SCORE2
    add al, '0'
    call WRITE_CHAR
    
    ret
GameOverScreen_multi ENDP

; ================= HELPER FUNCTIONS =================
CLEAR_SCREEN PROC
    mov ax, 0600h  ; Scroll entire window
    mov bh, 07h    ; Normal attribute
    mov cx, 0000h  ; Upper left corner
    mov dx, 184Fh  ; Lower right corner
    int 10h
    
    ; Move cursor to top-left
    mov dx, 0000h
    mov bh, 0
    mov ah, 2
    int 10h
    ret
CLEAR_SCREEN ENDP

NEW_LINE PROC
    mov ah, 0Eh
    mov al, 0Dh
    int 10h
    mov al, 0Ah
    int 10h
    ret
NEW_LINE ENDP

SET_CURSOR PROC
    ; DH = row, DL = column
    mov bh, 0
    mov ah, 2
    int 10h
    ret
SET_CURSOR ENDP

WRITE_CHAR PROC
    ; AL = character to write
    mov ah, 0Eh
    int 10h
    ret
WRITE_CHAR ENDP