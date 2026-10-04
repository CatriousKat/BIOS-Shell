[org 0x7c00]
bits 16

start:
    cli
    xor ax, ax
    mov ss, ax
    mov sp, 0x7c00
    mov ds, ax
    mov es, ax
    cld
    sti
    jmp cs_fn

ml:
    mov ax, 0x0e3e
    int 0x10
    mov di, buf
rd:
    xor ah, ah
    int 0x16
    cmp al, 13
    je ex
    cmp al, 8
    je .bs
    stosb
    mov ah, 0x0e
    int 0x10
    jmp rd
.bs:
    cmp di, buf
    jle rd
    dec di
    mov si, bs_str
    call pr
    jmp rd

ex:
    mov byte [di], 0
    mov si, nl
    call pr
    
    mov si, buf
    mov di, c_hlp
    call eq
    jc d_hlp

    mov di, c_cls
    call eq
    jc cs_fn

    mov di, c_mem
    call eq
    jc d_mem

    mov di, c_ech
    call ncmp
    jc d_ech

    mov di, c_dte
    call eq
    jc d_dte

    mov di, c_ext
    call eq
    jc d_ext

    call pr
    mov si, err_m
    jmp pr_l

d_hlp:
    mov si, h_txt
    jmp pr_l

d_mem:
    mov ax, 0xe801
    int 0x15
    jc .err
    test ax, ax
    jnz .s
    mov ax, cx
    mov bx, dx
.s:
    push bx
    mov cl, 10
    shr ax, cl
    pop bx
    shr bx, 4
    add ax, bx
    inc ax
    xor cx, cx
    mov bp, 10
.dl:
    xor dx, dx
    div bp
    push dx
    inc cx
    test ax, ax
    jnz .dl
.pl:
    pop ax
    add al, '0'
    call pc
    loop .pl
    mov si, mb_msg
    jmp pr_l
.err:
    mov si, err_m
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
    lodsb
    test al, al
    jz .d
    call pc
    jmp pr
.d:
    ret

pc:
    mov ah, 0x0e
    int 0x10
    ret

pb:
    push ax
    shr al, 4
    call .p
    pop ax
    and al, 0x0f
.p:
    add al, '0'
    jmp pc

eq:
    push si
    push di
.l:
    lodsb
    scasb
    jne .n
    test al, al
    jnz .l
    stc
    jmp .x
.n:
    clc
.x:
    pop di
    pop si
    ret

ncmp:
    push si
    push di
.sl:
    lodsb
    mov bl, [di]
    test bl, bl
    jz .y
    cmp al, bl
    jne .n
    inc di
    jmp .sl
.n:
    clc
    jmp .x
.y:
    stc
.x:
    pop di
    pop si
    ret

nl    db 13, 10, 0
err_m db ' err', 13, 10, 0
bs_str db 8, ' ', 8, 0
c_hlp db 'help', 0
c_cls db 'cls', 0
c_mem db 'mem', 0
c_ech db 'echo ', 0
c_dte db 'date', 0
c_ext db 'exit', 0
h_txt db 'help,cls,mem,echo,date,exit', 13, 10, 0
mb_msg db ' MB', 0

times 446-($-$$) db 0

db 0x80, 0x00, 0x01, 0x00, 0x01, 0xFF, 0xFF, 0xFF
dd 0x00000001, 0x00000B3F
times 48 db 0

dw 0xAA55

buf   equ 0x0500