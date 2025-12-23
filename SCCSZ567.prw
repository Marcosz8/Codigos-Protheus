#include 'Protheus.ch'
#include "FWMVCDEF.ch"

User Function SCCSZ567()
    
    Local oBrowse := FwLoadBrw("SCCSZ567")

    oBrowse:Activate()

Return

Static Function BrowseDef()
    
    Local aArea := GetArea()

    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias("SZ5")
    oBrowse:SetDescription("Cadastro de Chamados")

    oBrowse:AddLegend("SZ5->Z5_STATUS == '1'","RED", "ABERTO")
    oBrowse:AddLegend("SZ5->Z5_STATUS == '2'","ORANGE", "EM ATENDIMENTO")
    oBrowse:AddLegend("SZ5->Z5_STATUS == '3'","GREEN" , "ENCERRADO")

    // DEFINE DE ONDE SERÁ RETIRADO O MENUDEF
    oBrowse:SetMenuDef("SCCSZ567")

    oBrowse:DisableDetails()

    // RESTAURA A AREA DE TRABALHO ORIGINAL
    RestArea(aArea)

Return (oBrowse)

Static Function MenuDef()
    Local aRotina := {}
   
    ADD OPTION aRotina TITLE 'Visualizar' ACTION "VIEWDEF.SCCSZ567" OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Incluir'    ACTION "VIEWDEF.SCCSZ567" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'    ACTION "VIEWDEF.SCCSZ567" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'    ACTION "VIEWDEF.SCCSZ567" OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE 'Legenda'    ACTION "u_SZ3LEGND  "   OPERATION 6 ACCESS 0

return aRotina

// REGRAS DE NEGÓCIO
Static Function ModelDef()
    // INSTANCIA O MODELO
    Local oModel := MPFormModel():New("SZ567M")

    // INSTANCIA OS SUBMODELOS
    Local oStruSZ5 := FwFormStruct(1, "SZ5")
    Local oStruSZ6 := FwFormStruct(1, "SZ6")
    Local oStruSZ7 := FwFormStruct(1, "SZ7")
   
    // DEFINE SE OS SUBMODELOS SERÃO FIELD OU GRID
    oModel:AddFields("SZ5MASTER", NIL, oStruSZ5)
    oModel:AddGrid("SZ6DETAIL", "SZ5MASTER", oStruSZ6)
    oModel:AddGrid("SZ7DETAIL", "SZ6DETAIL", oStruSZ7)

    // DEFINE A RELAÇÃO ENTRE OS SUBMODELOS
    oModel:SetRelation("SZ6DETAIL", {{"Z6_FILIAL", "FwXFilial('SZ6')"}, {"Z6_NUMPROT", "Z5_NUMPROT"}}, SZ6->(IndexKey(1)))
    oModel:SetRelation("SZ7DETAIL", {{"Z7_FILIAL", "FwXFilial('SZ7')"}, {"Z7_NUMPROT", "Z5_NUMPROT"}, {"Z7_CODCHA", "Z6_CODCHA"}}, SZ7->(IndexKey(1)))

    // DEFINE A CHAVE PRIMARIA DA TABELA MASTER (SZ5)
    oModel:SetPrimaryKey({"Z5_FILIAL", "Z5_NUMPROT"})       
    
    // GARANTE UNICIDADE DO ITEM DENTRO DO GRID
    oModel:GetModel("SZ6DETAIL"):SetUniqueLine({"Z6_CODCHA"})
        
    // DESCRIÇÃO DO MODELO
    oModel:SetDescription("Sistema de Chamados")

    // DESCRIÇÃO DOS SUBMODELOS
    oModel:GetModel("SZ5MASTER"):SetDescription("Cadastro dos chamados")
    oModel:GetModel("SZ6DETAIL"):SetDescription("Andamento dos chamados")
    oModel:GetModel("SZ7DETAIL"):SetDescription("Informações | Comentários")
    
Return oModel

// INTERFACE GRÁFICA
Static Function ViewDef()
    // INSTANCIA A VIEW
    Local oView := FwFormView():New()

    // INSTANCIA AS SUBVIEWS
    Local oStruSZ5 := FwFormStruct(2, "SZ5")
    Local oStruSZ6 := FwFormStruct(2, "SZ6")
    Local oStruSZ7 := FwFormStruct(2, "SZ7")
    
    // RECEBE O MODELO DE DADOS
    Local oModel := FwLoadModel("SCCSZ567")

    // REMOVE CAMPOS DA EXIBIÇÃO
    oStruSZ6:RemoveField("Z6_NUMPROT")
    oStruSZ7:RemoveField("Z7_NUMPROT")
    oStruSZ7:RemoveField("Z7_CODCHA")
    
    // INDICA O MODELO DA VIEW
    oView:SetModel(oModel)

    // CRIA ESTRUTURA VISUAL DE CAMPOS
    oView:AddField("VIEW_SZ5", oStruSZ5, "SZ5MASTER")

    // CRIA A ESTRUTURA VISUAL DAS GRIDS
    oView:AddGrid("VIEW_SZ6", oStruSZ6, "SZ6DETAIL")
    oView:AddGrid("VIEW_SZ7", oStruSZ7, "SZ7DETAIL")

    // CAMPO INCREMENTAL PARA O ITEM
    oView:AddIncrementField("SZ6DETAIL","Z6_CODCHA")
    
    // CRIA BOXES HORIZONTAIS
    oView:CreateHorizontalBox("EMCIMA", 40)
    oView:CreateHorizontalBox("MEIO", 30)
    oView:CreateHorizontalBox("EMBAIXO", 30)

    // RELACIONA OS BOXES COM AS ESTRUTURAS VISUAIS
    oView:SetOwnerView("VIEW_SZ5", "EMCIMA")
    oView:SetOwnerView("VIEW_SZ6", "MEIO")
    oView:SetOwnerView("VIEW_SZ7", "EMBAIXO")

    // DEFINE OS TÍTULOS DAS SUBVIEWS
    oView:EnableTitleView("VIEW_SZ5","Cadastro dos chamados")
    oView:EnableTitleView("VIEW_SZ6", "Andamento dos chamados")
    oView:EnableTitleView("VIEW_SZ7", "Informações | Comentários")

Return oView

User Function SZ5LEGND() 
    
    Local aLegenda := {} 
    
    aAdd(aLegenda,{"BR_VERMELHO ", "CHAMADO ABERTO"})
    aAdd(aLegenda,{"BR_LARANJA ", "CHAMADO EM ANDAMENTO"})
    aAdd(aLegenda,{"BR_VERDE", "CHAMADO FECHADO" })

    BrwLegenda("STATUS CHAMADO",aLegenda)

Return aLegenda












                                                                                                                         
