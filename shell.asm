[org 0x7c00]
bits 16

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti
    mov ax, 0x0003
    int 0x10
    mov ax, 0x0100
    mov cx, 0x2607
    int 0x10
    call cs_fn

ml:
    mov ah, 0x0e
    mov al, '>'
    mov bx, 0x0007
    int 0x10
    mov di, buf
rd:
    xor ah, ah
    int 0x16
    cmp al, 13
    je ex
    cmp al, 8
    jne st_ch
    cmp di, buf
    jle rd
    dec di
    mov ax, 0x0e08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    jmp rd
st_ch:
    stosb
    mov ah, 0x0e
    int 0x10
    jmp rd

ex:
    mov byte [di], 0
    mov si, nl
    call pr
    
    mov si, buf
    mov di, c_hlp
    call eq
    jc d_hlp

    mov si, buf
    mov di, c_cls
    call eq
    jc cs_fn

    mov si, buf
    mov di, c_ver
    call eq
    jc d_ver

    mov si, buf
    mov di, c_ech
    call ncmp
    jc d_ech

    mov si, buf
    mov di, c_dte
    call eq
    jc d_dte

    mov si, buf
    mov di, c_ext
    call eq
    jc d_ext

    mov si, buf
    call pr
    mov si, err_m
    jmp pr_l

d_hlp:
    mov si, h_txt
    jmp pr_l

d_ver:
    mov si, v_msg
    jmp pr_l

cs_fn:
    mov ax, 0x0003
    int 0x10
    jmp ml

d_ech:
    mov si, buf + 5
    jmp pr_l

d_dte:
    mov ah, 0x04
    int 0x1a
    mov al, dl
    call pb
    mov al, '.'
    call pc
    mov al, dh
    call pb
    mov al, '.'
    call pc
    mov al, ch
    call pb
    mov al, cl
    call pb
    mov al, ' '
    call pc
    call pc
    mov ah, 0x02
    int 0x1a
    mov al, ch
    call pb
    mov al, ':'
    call pc
    mov al, cl
    call pb
    mov al, ':'
    call pc
    mov al, dh
    call pb
    jmp pr_n

d_ext:
    db 0xEA
    dw 0x0000, 0xFFFF

pr_l:
    call pr
pr_n:
    mov si, nl
    call pr
    jmp ml

pr:
    mov bx, 0x0007
pr_c:
    lodsb
    test al, al
    jz .d
    mov ah, 0x0e
    int 0x10
    jmp pr_c
.d:
    ret

pc:
    mov ah, 0x0e
    mov bx, 0x0007
    int 0x10
    ret

pb:
    push ax
    shr al, 4
    call .d
    pop ax
    and al, 0x0f
.d:
    add al, '0'
    jmp pc

eq:
    push si
    push di
.l:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .n
    test al, al
    jz .y
    inc si
    inc di
    jmp .l
.y:
    pop di
    pop si
    stc
    ret
.n:
    pop di
    pop si
    clc
    ret

ncmp:
    push si
    push di
.sl:
    mov bl, [di]
    test bl, bl
    jz .y
    lodsb
    cmp al, bl
    jne .n
    inc di
    jmp .sl
.n:
    pop di
    pop si
    clc
    ret
.y:
    pop di
    pop si
    stc
    ret

nl    db 13, 10, 0
err_m db ' bad cmd', 13, 10, 0
c_hlp db 'help', 0
c_cls db 'cls', 0
c_ver db 'ver', 0
c_ech db 'echo ', 0
c_dte db 'date', 0
c_ext db 'exit', 0
h_txt db 'help,cls,ver,echo,date,exit', 13, 10, 0
v_msg db 'BIOS Shell v1.0', 0

times 510-($-$$) db 0
dw 0xAA55

buf   equ $