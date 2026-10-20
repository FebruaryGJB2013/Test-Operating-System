[org 0x7c00]            ; BIOS bootloader offset

start:
    ; 1. Switch to VGA Graphics Mode 13h (320x200, 256 colors)
    mov ah, 0x00
    mov al, 0x13
    int 0x10

    ; 2. Draw a static "Boot Icon" (a blue 40x40 square in the center)
    ; Center is roughly X=140, Y=80
    mov cx, 140         ; Starting X
    mov dx, 80          ; Starting Y
draw_icon_y:
    mov cx, 140         ; Reset X for next row
draw_icon_x:
    mov ah, 0x0c        ; BIOS write pixel function
    mov al, 1           ; Color blue
    mov bh, 0           ; Page 0
    int 0x10
    inc cx
    cmp cx, 180         ; Width = 40 pixels
    jl draw_icon_x
    inc dx
    cmp dx, 120         ; Height = 40 pixels
    jl draw_icon_y

    ; 3. Fake "Loading" Animation (Drawing a moving line below the icon)
    mov bx, 0           ; Animation counter
loading_loop:
    ; Draw a pixel that moves horizontally to simulate progress
    mov ah, 0x0c
    mov al, 14          ; Color yellow
    mov cx, 110
    add cx, bx          ; Shift X based on counter
    mov dx, 140         ; Y position for loading bar
    int 0x10

    ; Tiny delay loop to slow down emulation
    mov ecx, 5000000
delay:
    loop delay

    inc bx
    cmp bx, 100         ; Loop 100 times
    jl loading_loop

    ; 4. Clear screen back to text mode to say "Test Complete"
    mov ah, 0x00
    mov al, 0x03        ; Standard 80x25 text mode
    int 0x10

    ; Print success message
    mov si, msg
print_string:
    lodsb
    or al, al
    jz hang
    mov ah, 0x0e
    int 0x10
    jmp print_string

hang:
    jmp hang            ; Infinite loop to keep OS running

msg db 'TEST COMPLETE!', 0

times 510-($-$$) db 0   ; Pad remaining bytes with 0
dw 0xaa55               ; Boot signature
