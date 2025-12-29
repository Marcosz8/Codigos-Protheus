#include "Protheus.ch"

User Function Item()

    Local aParam := PARAMIXB

    Local xRet   := .T.

    Local oObject   := aParam[1] 
    Local cIdPonto  := aParam[2] 
    Local cIdModel  := aParam[3] 

   
    Local nOperation := oObject:GetOperation()

    IF aParam[2] <> Nil 

        IF cIdPonto == "MODELPOS" 
            
            IF AllTrim(M->B1_TIPO) == "MC"

                IF Alltrim(M->B1_LOCPAD) != "04"
               
                    Help(NIL, NIL, "ARMZ.PADRÃO",NIL,"Código não permitido",1,0,NIL,NIL,NIL,NIL,NIL,{"O Codigo deve igual a 04 pois foi escolhido tipo MC."})
                   
                    xRet := .F.
                ENDIF
                IF Alltrim(M->B1_LOCPAD) == "04" 
                    
                    IF !( Alltrim(M->B1_GRUPO) $ "0009/0010" ) //Alltrim(M->B1_GRUPO) != "0009" .AND. Alltrim(M->B1_GRUPO) != "0010"
                    
                        Help(NIL, NIL, "GRUPOPADRAO",NIL,"Código não permitido",1,0,NIL,NIL,NIL,NIL,NIL,{"Quando o armazém 04 está selecionado você deve escolher grupo 0009 ou 0010"})
                   
                        xRet := .F.
                    ENDIF          
                    IF xRet .AND. Alltrim(M->B1_GRUPO) == "0009"
                        
                        IF Alltrim(M->B1_TE) != "003"
                            
                            Help(NIL, NIL, "TESPADRAO",NIL,"TE Padrão selecionada não permitida",1,0,NIL,NIL,NIL,NIL,NIL,{"A TE deve ser igual a 003 com grupo 0009 selecionado."})
               
                            xRet := .F.               
                        ENDIF 
                    ENDIF
                   
                    IF  xRet .AND. Alltrim(M->B1_GRUPO) == "0010"
                        
                        IF Alltrim(M->B1_TE) != "010"
                            
                            Help(NIL, NIL, "TESPADRAO",NIL,"TE Padrão selecionada não permitida",1,0,NIL,NIL,NIL,NIL,NIL,{"A TE deve ser igual a 010 com grupo 0010 selecionado"})
               
                            xRet := .F.               
                        ENDIF 
                    ENDIF
                ENDIF
            ENDIF
        ENDIF
    ENDIF

Return xRet
