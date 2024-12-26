.model small
.stack 100h
.data
    msj1 db "Introduceti coeficientul lui x^2: ",10,"$"   ; Mesaj pentru a solicita coeficientul lui x^2
    msj2 db 10,13,"Introduceti coeficientul lui x:",10,"$"  ; Mesaj pentru a solicita coeficientul lui x
    msj3 db 10,13,"Introduceti coeficientul termenului liber:",10,"$" ; Mesaj pentru a solicita termenul liber
    msj4 db 10,13,"Delta este b^2-4ac",10,"$"   ; Mesaj care descrie formula discriminantului (Delta)
    msj5 db 10,13,"Delta este negativ , ecuatia nu are solutii reale$" ; Mesaj pentru delta negativ
    msj6 db 10,13,"Radacina dubla $"  ; Mesaj pentru a semnala că există o radăcină dublă
    eroare db 10,13,"Ecuatia nu este de gradul 2$"
    b dw ?   ; Coeficientul b
    a dw ?   ; Coeficientul a
    c dw ?   ; Coeficientul c
    delta dw ?  ; Variabila pentru delta (discriminant)
    semn db ?  ; Variabila pentru semnul numărului citit
.code
    
; Procedura de citire a unui număr
citireNumar PROC
    mov ax,@data
    mov ds,ax
    mov cx,10          ; Setăm baza pentru număr (baza 10 pentru numere zecimale)
    mov semn,0         ; Inițializăm semnul numărului ca pozitiv
    mov ah,01h         ; Funcție pentru citirea unui caracter
    int 21h            ; Citim caracterul
    cmp al,'-'         ; Verificăm dacă este semnul minus
        je negativ     ; Dacă da, trecem la secțiunea de numere negative
        sub al,48       ; Dacă nu, convertim caracterul în valoarea numerică (ASCII -> valoare)
        xor bx,bx       ; Resetăm registrul bx
        mov bl,al       ; Salvăm cifra citită în registrul bx
        push bx         ; Salvăm cifra pe stivă
        xor bx,bx       ; Resetăm registrul bx
        jmp citireCifra ; Continuăm citirea următoarei cifre

    negativ:
        mov semn,1      ; Marcam că numărul este negativ
        xor bx,bx       ; Resetăm registrul bx
        push bx         ; Salvăm 0 pe stivă pentru a păstra semnul

    citireCifra:
        mov ah,01h      ; Citim un alt caracter
        int 21h         ; Funcția de citire a caracterului
        cmp al,13       ; Verificăm dacă s-a apăsat Enter (caracterul de sfârșit)
            je numarCitit ; Dacă da, ieșim din citire
        sub al,48       ; Convertim cifra citită
        mov bl,al       ; Salvează cifra în registrul bx
        pop ax          ; Recuperează valoarea anterioară a numărului
        mul cx          ; Multiplicăm ax cu baza (10)
        add ax,bx       ; Adunăm cifra la valoarea curentă
        push ax         ; Salvăm valoarea actualizată
        jmp citireCifra ; Continuăm citirea cifrei următoare

    numarCitit:
        pop ax          ; Recuperează valoarea finală a numărului
        cmp semn,1      ; Verificăm dacă numărul este negativ
            jne pozitiv ; Dacă nu, trecem la conversia unui număr pozitiv
        neg ax          ; Negăm numărul pentru a-l face negativ

    pozitiv:
        ret             ; Returnăm valoarea numărului citit
citireNumar ENDP

; Procedura pentru afisarea unui număr
afisareNumar PROC
    mov bx,10        ; Setăm baza 10 pentru a descompune numărul
    xor cx,cx        ; Resetează contorul pentru numărul de cifre
    cmp ax,0         ; Verificăm dacă numărul este 0
        jge descompunere ; Dacă numărul este mai mare sau egal cu 0, descompunem
    neg ax           ; Dacă numărul este negativ, îl facem pozitiv
    push ax          ; Salvăm numărul pe stivă
    mov dl,'-'       ; Afișăm semnul minus
    mov ah,02h       ; Funcție de afișare a unui caracter
    int 21h          ; Afișăm semnul minus
    pop ax           ; Recuperează valoarea numărului
    descompunere:
        xor dx,dx     ; Resetăm restul
        div bx        ; Împărțim numărul la 10
        push dx       ; Salvăm restul pe stivă
        inc cx        ; Incrementăm contorul de cifre
        cmp ax,0      ; Verificăm dacă mai sunt cifre de afisat
            je afisare ; Dacă nu, afișăm rezultatul
        jmp descompunere ; Continuăm descompunerea

    afisare:
        pop dx        ; Recuperează ultima cifră
        add dx,48     ; Convertim cifra în caracter ASCII
        mov ah,02h     ; Funcție de afișare a unui caracter
        int 21h        ; Afișăm cifra
    loop afisare      ; Continuăm până la afișarea tuturor cifrelor
    ret               ; Returnăm din procedură
afisareNumar ENDP

main:
    mov ax,@data
    mov ds,ax

    ; Macro pentru a afișa mesaje
    mesaj MACRO msj
        mov ah,09h
        lea dx,msj
        int 21h
    ENDM

    mesaj msj1       ; Afișăm mesajul pentru coeficientul lui x^2
    call citireNumar ; Citim coeficientul lui x^2
    mov a,ax       ; Salvăm coeficientul a
    cmp a,0
        je eroare_impartire 
    mesaj msj2       ; Afișăm mesajul pentru coeficientul lui x
    call citireNumar ; Citim coeficientul lui x
    mov b,ax         ; Salvăm coeficientul b

    mesaj msj3       ; Afișăm mesajul pentru termenul liber
    call citireNumar ; Citim termenul liber
    mov c,ax         ; Salvăm coeficientul c

    ; Calculăm discriminantul (Delta) = b^2 - 4ac
    mov bx,b         ; Pregătim b pentru multiplicare
    mov ax,b         ; Calculăm b^2
    mul bx
    mov delta,ax     ; Salvăm b^2 în delta
    mov ax,c         ; Calculăm 4ac
    mov bx,a
    mul bx
    mov bx,4         ; Înmulțim cu 4
    mul bx
    sub delta,ax     ; Delta = b^2 - 4ac

    mesaj msj4       ; Afișăm mesajul pentru delta
    mov ax,delta
    call afisareNumar ; Afișăm valoarea lui delta

    mov ax,delta     ; Comparăm delta cu 0
    cmp ax,0
        je radacinaDubla ; Dacă delta este 0, avem rădăcină dublă
    jl delta_negativ  ; Dacă delta este negativ, nu există soluții reale

    jmp terminare

radacinaDubla:
    mesaj msj6       ; Afișăm mesajul pentru rădăcina dublă
    mov ax,b
    neg ax            ; Calculăm -b
    mov bx,a
    add bx,a          ; Înmulțim a cu 2 (2a)    
    div bx           ; Împărțim -b la 2a
    call afisareNumar ; Afișăm rădăcina dublă

    jmp terminare

eroare_impartire:
    mesaj eroare
    jmp terminare

delta_negativ:
    mesaj msj5       ; Afișăm mesajul pentru delta negativ
    jmp terminare

terminare:
    mov ah,4ch       ; Terminăm programul
    int 21h
end main