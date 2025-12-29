#include "Protheus.ch"

/*
    -------------------------------------------------------------------------
    Ponto de entrada: Item
    Finalidade:
    Valida regras de negócio no cadastro de produtos (SB1),
    garantindo coerência entre Tipo do Item, Armazém Padrão,
    Grupo de Produto e TES.
    -------------------------------------------------------------------------
*/


User Function Item()

    // Parâmetros recebidos pelo ponto de entrada
    Local aParam := PARAMIXB

    // Variável de retorno (TRUE permite gravação / FALSE bloqueia)
    Local xRet   := .T.

    Local oObject   := aParam[1] // Objeto do MVC
    Local cIdPonto  := aParam[2] // Identificador do ponto de entrada
    Local cIdModel  := aParam[3] // Identificador do Model

   // Operação atual
    Local nOperation := oObject:GetOperation()

    IF aParam[2] <> Nil // Valida se o ponto de entrada foi corretamente identificado 

        IF cIdPonto == "MODELPOS" // Executa apenas no pós-processamento do Model
            
            IF AllTrim(M->B1_TIPO) == "MC"// Regra aplicada somente para itens do tipo MC

                IF Alltrim(M->B1_LOCPAD) != "04" // Validação do Armazém Padrão, Para tipo MC, o armazém deve ser obrigatoriamente "04"
               
                    Help(NIL, NIL, "ARMZ.PADRÃO",NIL,"Código não permitido",1,0,NIL,NIL,NIL,NIL,NIL,{"O Codigo deve igual a 04 pois foi escolhido tipo MC."})
                   
                    xRet := .F.
                ENDIF
                IF Alltrim(M->B1_LOCPAD) == "04" // Se o armazém for 04, aplica regras adicionais
                    
                    IF !( Alltrim(M->B1_GRUPO) $ "0009/0010" ) // Grupo permitido apenas 0009 ou 0010
                    
                        Help(NIL, NIL, "GRUPOPADRAO",NIL,"Código não permitido",1,0,NIL,NIL,NIL,NIL,NIL,{"Quando o armazém 04 está selecionado você deve escolher grupo 0009 ou 0010"})
                   
                        xRet := .F.
                        // Se grupo for 0009, TES obrigatória é 003   
                        IF xRet .AND. Alltrim(M->B1_GRUPO) == "0009"
                        
                            IF Alltrim(M->B1_TE) != "003"
                            
                                Help(NIL, NIL, "TESPADRAO",NIL,"TE Padrão selecionada não permitida",1,0,NIL,NIL,NIL,NIL,NIL,{"A TE deve ser igual a 003 com grupo 0009 selecionado."})
               
                                xRet := .F.               
                            ENDIF 
                        ENDIF
                        // Se grupo for 0010, TES obrigatória é 010
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
    ENDIF

Return xRet
