cr equ 0dh
lf equ 0ah
;_________________________________________________
data segment 
	msg1 db cr,lf,'Enter file name: $'
	msg2 db cr,lf,'Enetr string (Case sensitive!): $'
	msg3 db cr,lf,'Number repet string: $'
	msg4 db cr,lf,'The string not found in the file!',cr,lf,'$'
	msg5 db cr,lf,'Press any key to Exit...$'
	cunter dw 0
	n dw 0
	filename db 43 dup(?)
	string db 23 dup(?)
	tmpstr db 20 dup(?)
	output db 7 dup(0)
	readstr db 20 dup(0)
	handel dw ?
	err1 db cr,lf,'Unabel open the file!',cr,lf,'$'
	err2 db cr,lf,'Error reading file!',cr,lf,'$'
	err3 db cr,lf,'Error closing file!',cr,lf,'$'
	err4 db cr,lf,'Input string is NULL!',cr,lf,'$'
data ends
;___________________________________________________
code segment
	Assume ds:data,cs:code
start:
	mov ax,data
	mov ds,ax

	mov ah,09h
	mov dx,offset msg1
	int 21h

	mov ah,0ah
	mov dx,offset filename
	mov filename,40
	int 21h

	mov ah,09h
	mov dx,offset msg2
	int 21h

	mov ah,0ah
	mov dx,offset string
	mov string,20
	int 21h
	
	mov bx,offset filename
	mov ax,0000
	mov al,filename+1
	add bx,ax
	mov byte ptr[bx+2],0

	mov bx,offset string
	cmp byte ptr[bx+1],0
	
	jnz ok
	mov ah,09h
    mov dx,offset err4
    int 21h
    jmp exit
ok:
	mov ax,0
	mov al,string+1
	mov n,ax
	add bx,ax
	mov byte ptr[bx+2],0
    
	;________________________open the file_________________________	
	mov al,0 
	mov ah,3dh
	mov dx,offset filename+2
	int 21h
	jnc read
	mov ah,09h
	mov dx,offset err1
	int 21h
	jmp exit
	
read:	
    mov handel,ax
	mov bx,ax
	
    mov ah,3fh
    mov dx,offset readstr
	mov cx,n
	int 21h
while: cmp ax,0
    jz end_while 
    mov si,offset string+2
    mov di,offset readstr
    mov ax,ds
    mov es,ax
    mov cx,n
    repe cmpsb
    jnz noe
    inc cunter
noe:
    mov si,offset readstr+1
    mov di,offset readstr 
    mov ax,ds
    mov es,ax
    cld
    mov cx,n
    dec cx
    rep movsb
    
    mov cx,1
    mov ah,3fh 
    mov dx,offset readstr
    add dx,n
    dec dx
    int 21h
    jmp while
end_while:

    mov ah,3eh
    mov bx,handel
    int 21h
    jnc fileclosed
    mov ah,09h
    mov dx,offset err3
    int 21h
fileclosed:
    cmp cunter,0
    jz NoStr
    mov ax,cunter
    mov dx,10
    mov si,offset tmpstr
while1:  cmp ax ,0
    jz end_while1
    div dl
    mov bl,ah
    mov bh,0
    add bx,30h
    mov [si],bl
    inc si
    mov ah,0
    inc cx
    jmp while1
end_while1:
 
    mov di,offset output
    dec cx
    copy:
    dec si
    mov al,[si]
    mov [di],al
    inc di
    loop copy
    mov byte ptr[di],'$'
    jmp  j
    
nostr:
    mov ah,09h
    mov dx,offset msg4
    int 21h 
    jmp exit
j:
    mov ah,09h
    mov dx,offset msg3
    int 21h
    mov dx,offset output
    int 21h
    
exit:     mov ah,09h
    mov dx,offset msg5
    int 21h 
    mov ah,0
    int 16h	
    mov ax,4c00h
	int 21h
code ends
	end start

	
