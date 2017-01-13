
    
      *=$0801     
; code for making code runnable (basic sys line)
                .byte $0c,$08,0,0,$9e,$32,$30,$38,$30,0,0,0,"E","X","T"
                
                * = $0820    
; generate y-tables for pixel plotter
                ldx #0
lo              lda #$00
                sta ytablelo,x
hi              lda #$20
                sta ytablehi,x

                inc lo+1
                lda lo+1
                and #$07
                bne norowadd
                
                lda lo+1
                clc
                adc #$38
                sta lo+1
                lda hi+1
                adc #$01
                sta hi+1                
norowadd        inx
                cpx #60
                bne lo

; initialize screen / graphics mode                   
                lda #0
                sta $d020
                sta $d021
                
                ldx #0
lp1             lda #$10
                sta $0400,x
                sta $0500,x
                sta $0600,x
                sta $0700,x
                sta $d800,x
                sta $d900,x
                sta $da00,x
                sta $db00,x
                inx
                bne lp1
                
                lda #$3b
                sta $d011
                lda #$18
                sta $d018
                lda #$c8
                sta $d016                                 
                
                ; use ram > $a000
                lda #$36
                sta $01                
; start main loop                               
start                                           
                ldx rgbpos
                ldy rgbpos+1
                jsr comparefunc ; compare rgb values                                            
                cmp #0          ; found draw up
                beq draw
                cmp #1          ; found draw left
                beq draw                  
                cmp #255        ; end of file
                beq done
                                  
                ; advance and update coordinates                            
continue          
                lda rgbpos
                clc
                adc #3    
                sta rgbpos
                lda rgbpos+1
                adc #0
                sta rgbpos+1
                          
                inc c64x
                lda c64x
                cmp #180
                bne nolinechange
                
                ; change c64 y-position and reset x-position
                inc c64y
                lda #0
                sta c64x

nolinechange    jmp start             

                ; done flash border
done            inc $d020
                jmp done

                ; start drawing pixels until stop found
                ; a=start direction                           
draw            sta drawdir
              
                ; copy current rgb location
                lda rgbpos
                sta drawrgbpos
                lda rgbpos+1
                sta drawrgbpos+1
                
                ; copy current c64 x/y pos    
                lda c64x
                sta drawposx
                lda c64y
                sta drawposy
                
                ; draw first pixel                                                                          
loopdraw        ldx drawposx
                ldy drawposy
                jsr setpixel                

                lda drawdir                                                                       
                cmp #0
                beq up                                
                cmp #1
                beq left
                cmp #2
                beq down
                cmp #3
                beq right
                cmp #4      ; drawing stopped
                beq continue                          
                                            
                ; get next action               
drawnext        ldx drawrgbpos
                ldy drawrgbpos+1
                jsr comparefunc
                cmp #2
                beq stop
                cmp #3
                beq turnright
                cmp #4
                beq turnleft                                
                jmp loopdraw                

                ;move up                
up              dec drawposy      
                lda drawrgbpos
                sec
                sbc #$1c
                sta drawrgbpos
                lda drawrgbpos+1
                sbc #$02
                sta drawrgbpos+1
                jmp drawnext

                ;move left
left            dec drawposx                    
                lda drawrgbpos
                sec
                sbc #3
                sta drawrgbpos
                lda drawrgbpos+1
                sbc #0
                sta drawrgbpos+1                
                jmp drawnext

                ;move down
down            inc drawposy                                
                lda drawrgbpos
                clc
                adc #$1c
                sta drawrgbpos
                lda drawrgbpos+1
                adc #$02
                sta drawrgbpos+1
                jmp drawnext
                
                ;move right
right           inc drawposx            
                lda drawrgbpos
                clc
                adc #3
                sta drawrgbpos
                lda drawrgbpos+1
                adc #0
                sta drawrgbpos+1
                jmp drawnext
                            
                ;stop drawing   
stop            lda #4
                sta drawdir             
                jmp loopdraw
                
                ;change draw dir
turnright       dec drawdir
                lda drawdir
                and #3
                sta drawdir
                jmp loopdraw
                
                ;change draw dir
turnleft        inc drawdir
                lda drawdir
                and #3
                sta drawdir
                jmp loopdraw                        
                    
                ;setpixel at x/y              
setpixel        lda ytablelo,y
                sta $50
                lda ytablehi,y
                sta $51
                
                ;calculate pixel index
                txa
                pha
                and #$07
                tax 
                            
								;calculate column                                
                pla
                lsr
                lsr
                lsr
                asl
                asl
                asl
                tay               
    
                lda bittable,x
                ora ($50),y
                sta ($50),y                               
                rts               

comparefunc     stx $70
                sty $71
                
                ldx #0          
compareloop     ldy #0
                lda ($70),y
                cmp rtbl,x
                bne notfound
                iny
                lda ($70),y
                cmp gtbl,x
                bne notfound
                iny
                lda ($70),y
                cmp btbl,x
                bne notfound
                
                ; found match
                ; read result from result table
                lda restbl,x
                rts                                 
                
                ; no match continue reading
notfound        inx
                cpx #6
                bne compareloop
                
                lda #$07 ; nothing found return non-used value
                rts
          
; variables                        
c64x            .byte 0
c64y            .byte 0   
drawdir         .byte 0                                 
rgbpos          .word rgb
drawrgbpos      .word $0000
drawposx        .byte 0
drawposy        .byte 0                               
bittable        .byte $80,$40,$20,$10,$08,$04,$02,$01             

; rgb comparison table
rtbl            .byte  7,139, 51,182,123,255
gtbl            .byte 84, 57, 69,149,131,255
btbl            .byte 19,137,169, 72,154,255
restbl          .byte  0, 1,  2,  3,  4, 255

                * = $1100
; generated y-table for pixel drawing
ytablelo        
                * = $1200
ytablehi      

                * = $4000     
; include secret message picture in r,g,b values
rgb             .binary c64rgb  
; add eof marker
                .byte 255,255,255 