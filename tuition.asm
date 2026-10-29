
%macro print_text 2
    mov ecx, %1
    mov edx, %2
    call print_proc
%endmacro

%macro read_input 2
    mov ecx, %1
    mov edx, %2
    call input_proc
%endmacro

section .data
    title_msg db 10, "=== COR TUITION FEE COMPUTATION ===", 10
    title_len equ $-title_msg

    prompt db "Enter number of units: "
    prompt_len equ $-prompt

    tuition_msg db "Tuition Fee: PHP "
    tuition_len equ $-tuition_msg

    total_msg db "Total Assessment: PHP "
    total_len equ $-total_msg

    down_msg db "Down Payment (40%): PHP "
    down_len equ $-down_msg

    mid_msg db "Midterm (30%): PHP "
    mid_len equ $-mid_msg

    final_msg db "Final (30%): PHP "
    final_len equ $-final_msg

    newline db 10

    rate dd 2108
    other_fees dd 28513

section .bss
    input resb 16
    units resd 1
    tuition resd 1
    total resd 1
    down resd 1
    mid resd 1
    final resd 1
    number resb 16

section .text
    global _start

_start:
    print_text title_msg, title_len

    ; INPUT
    print_text prompt, prompt_len
    read_input input, 16

    ; Convert input to integer
    mov esi, input
    call string_to_int
    mov [units], eax

    ; Compute tuition
    mov eax, [units]
    mul dword [rate]
    mov [tuition], eax

    ; Compute total assessment
    add eax, [other_fees]
    mov [total], eax

    ; Compute down payment (40%)
    mov eax, [total]
    mov ebx, 40
    mul ebx
    mov ebx, 100
    div ebx
    mov [down], eax

    ; Compute midterm (30%)
    mov eax, [total]
    mov ebx, 30
    mul ebx
    mov ebx, 100
    div ebx
    mov [mid], eax

    ; Compute final payment
    mov eax, [total]
    sub eax, [down]
    sub eax, [mid]
    mov [final], eax

    ; OUTPUT
    print_text tuition_msg, tuition_len
    mov eax, [tuition]
    call print_money

    print_text total_msg, total_len
    mov eax, [total]
    call print_money

    print_text down_msg, down_len
    mov eax, [down]
    call print_money

    print_text mid_msg, mid_len
    mov eax, [mid]
    call print_money

    print_text final_msg, final_len
    mov eax, [final]
    call print_money

    ; Exit
    mov eax, 1
    xor ebx, ebx
    int 0x80

; PROCEDURE: Print text
print_proc:
    push ebx
    mov eax, 4
    mov ebx, 1
    int 0x80
    pop ebx
    ret

; PROCEDURE: Read input
input_proc:
    mov eax, 3
    mov ebx, 0
    int 0x80
    ret

; PROCEDURE: Convert string to integer
string_to_int:
    xor eax, eax
    xor ebx, ebx

.convert:
    mov bl, [esi]
    cmp bl, 10
    je .done
    cmp bl, 0
    je .done
    cmp bl, '0'
    jb .done
    cmp bl, '9'
    ja .done

    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx
    inc esi
    jmp .convert

.done:
    ret

; PROCEDURE: Print money with 2 decimals
print_money:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov edi, number
    add edi, 15
    mov byte [edi], 10

    ; All money values are in pesos
    ; Add .00 to the output
    dec edi
    mov byte [edi], '0'
    dec edi
    mov byte [edi], '0'
    dec edi
    mov byte [edi], '.'

    mov ebx, 10
    mov esi, 0

.convert:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    inc esi
    test eax, eax
    jnz .convert

    mov ecx, edi
    mov edx, number
    add edx, 16
    sub edx, ecx
    call print_proc

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
