#include 'Protheus.ch'
#include "FWMVCDEF.ch"

/*
    -------------------------------------------------------------------------
    ROTINA: SITSZ3
    DESCRIÇÃO:
    Cadastro de Solicitação de Compras (Pedidos de Peças e Itens de Oficina)
    Desenvolvido utilizando MVC Modelo 2 (MPFormModel / FwFormView)
    -------------------------------------------------------------------------
*/

/*
    -------------------------------------------------------------------------
    Função principal
    Responsável por abrir o Browse principal (FWMBrowse)
    -------------------------------------------------------------------------
*/

User Function SITSZ3()
    
    // Salva a área de trabalho atual
    Local aArea := GetArea()
    Local oBrowseSZ3 

    // Instancia o browse padrão do framework
    oBrowseSZ3 := FwmBrowse():New()

    // Define o alias da tabela principal
    oBrowseSZ3:SetAlias("SZ3")
    
    // Define a descrição/título do browse
    oBrowseSZ3:SetDescription("Pedidos e peças oficina")

    // Legendas visuais baseadas no nível de urgência do pedido
    oBrowseSZ3:AddLegend("SZ3->Z3_URGPEDI == '1'", "GREEN", "NORMAL")
    oBrowseSZ3:AddLegend("SZ3->Z3_URGPEDI == '2'", "BLUE", "PREFERENCIAL")
    oBrowseSZ3:AddLegend("SZ3->Z3_URGPEDI == '3'","ORANGE" , "ALTA PRIORIDADE")
    oBrowseSZ3:AddLegend("SZ3->Z3_URGPEDI == '4'", "RED", "URGENTE")

     // Desabilita o painel de detalhes padrão do browse (lado direito)
    oBrowseSZ3:DisableDetails()

    // Ativa/exibe o browse
    oBrowseSZ3:Activate()
   
    // Restaura a área de trabalho original
    RestArea(aArea)

return

Static Function MenuDef()
    Local aRotina := {}
   
    ADD OPTION aRotina TITLE 'Visualizar' ACTION "VIEWDEF.SITSZ3" OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Incluir'    ACTION "VIEWDEF.SITSZ3" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'    ACTION "VIEWDEF.SITSZ3" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'    ACTION "VIEWDEF.SITSZ3" OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE 'Legenda'    ACTION "u_SZ3LEGND  "   OPERATION 6 ACCESS 0

return aRotina

Static Function ModelDef()
         
    // Instancia o modelo principal MVC
    Local oModel := MPFormModel():New("SITSZ3M")
    
    // Arrays que armazenarão os gatilhos de cálculo Quantidade x Preço = Total
    Local aTrigQuant := {}
    Local aTrigPreco := {}

    // Estruturas dos modelos (1 = Model)
    Local oStruSZ3 := FwFormStruct(1, "SZ3") // Cabeçalho
    Local oStruSZ4 := FwFormStruct(1, "SZ4") // Itens

    //Criação das triggers: Sempre que quantidade ou preço mudar, o campo total será recalculado automaticamente
    aTrigQuant := FwStruTrigger("Z4_QUANT", "Z4_TOTAL","M->Z4_QUANT*M->Z4_PRECO",.F.)
    aTrigPreco := FwStruTrigger("Z4_PRECO", "Z4_TOTAL","M->Z4_QUANT*M->Z4_PRECO",.F.)

    // Adiciona as triggers à estrutura dos itens
    oStruSZ4:AddTrigger(aTrigQuant[1],aTrigQuant[2],aTrigQuant[3],aTrigQuant[4])
    oStruSZ4:AddTrigger(aTrigPreco[1],aTrigPreco[2],aTrigPreco[3],aTrigPreco[4])

    // Valores padrão automáticos no cabeçalho
    oStruSZ3:SetProperty('Z3_USER',   MODEL_FIELD_INIT, {|| RetCodUsr()})
    oStruSZ3:SetProperty('Z3_DATEMI', MODEL_FIELD_INIT, {|| dDataBase})

    // Define se os subodelos serão Field ou Grid
    oModel:AddFields("SZ3MASTER", NIL, oStruSZ3)
    oModel:AddGrid("SZ4DETAIL", "SZ3MASTER", oStruSZ4)
    
    //Adiciona Model de totalizadores a aplicação
    oModel:AddCalc("SZ4TOTAL", "SZ3MASTER","SZ4DETAIL","Z4_PECA",     "QTDPECAS",      "COUNT",,,"Número de tipos de peças")
    oModel:AddCalc("SZ4TOTAL", "SZ3MASTER","SZ4DETAIL","Z4_QUANT",    "QTDTOTAL",      "SUM",,,  "Quantidade total de peças")
    oModel:AddCalc("SZ4TOTAL", "SZ3MASTER","SZ4DETAIL","Z4_TOTAL",    "VALORTOTAL",    "SUM",,,  "Valor final do pedido ")
    
    // Relacionamento entre cabeçalho e itens
    oModel:SetRelation("SZ4DETAIL",{{"Z4_FILIAL", "FwXFilial('SZ4')"}, {"Z4_NUMPED", "Z3_NUMPED"}}, SZ4->(IndexKey( 1 ))) 

    // Define chave primária conforme dicionário (X2_UNICO)
    oModel:SetPrimaryKey({})

    // Garante unicidade do item dentro do grid
    oModel:GetModel("SZ4DETAIL"):SetUniqueLine({"Z4_ITEM"}) 

    // Descrições exibidas na tela
    oModel:SetDescription("Cadastro de pedido de Peças")
    oModel:GetModel("SZ3MASTER"):SetDescription("Cabeçalho da solicitação de compras")
    oModel:GetModel("SZ4DETAIL"):SetDescription("Itens da solicitação de compras")
    
Return oModel

Static Function ViewDef()
            
    // Instancia a view principal
    oView := FwFormView():New()

    // Instancia as subviews
    Local oStruSZ3 := FwFormStruct(2, "SZ3")
    Local oStruSZ4 := FwFormStruct(2, "SZ4")

    // Carrega o modelo
    Local oModel := FwLoadModel("SITSZ3")

    // Estrutura de visualização dos totalizadores
    Local oStruTotal := FwCalcStruct(oModel:GetModel("SZ4TOTAL"))
        
    // Associa modelo à view
    oView:SetModel(oModel)

    //Bloqueando a edição dos campos especificos
    oStruSZ3:SetProperty("Z3_USER", MVC_VIEW_CANCHANGE,.F.)
    oStruSZ4:SetProperty("Z4_ITEM", MVC_VIEW_CANCHANGE,.F.)
    oStruSZ4:SetProperty("Z4_TOTAL", MVC_VIEW_CANCHANGE,.F.)
    
    // Remove campo que não deve aparecer na grid
    oStruSZ4:RemoveField("Z4_NUMPED")
    
    // Monta a estrutura de vizualização do Master, Detalhe e Totalizadores.
    oView:AddField("VIEW_SZ3M",oStruSZ3,"SZ3MASTER") 
    oView:AddGrid("VIEW_SZ4D",oStruSZ4,"SZ4DETAIL") 
    oView:AddField("VIEW_TOTAL",oStruTotal,"SZ4TOTAL")
        
    // Campo incremental para o item
    oView:AddIncrementField("SZ4DETAIL","Z4_ITEM")

    // Cria a tela, dividindo proporcionalmente o tamanho conforme configurado
    oView:CreateHorizontalBox("CABEC",30) 
    oView:CreateHorizontalBox("GRID",50) 
    oView:CreateHorizontalBox("TOTAL",20) 

    // Associação das views aos boxes criados acima
    oView:SetOwnerView("VIEW_SZ3M","CABEC")
    oView:SetOwnerView("VIEW_SZ4D","GRID")
    oView:SetOwnerView("VIEW_TOTAL","TOTAL")
    
    // Ativa os títulos de cada View/Box criado
    oView:EnableTitleView("VIEW_SZ3M", "Cabeçalho Solicitação de Compras")
    oView:EnableTitleView("VIEW_SZ4D", "Itens da Solicitação de Compras")
    oView:EnableTitleView("VIEW_TOTAL", "Resumo da Solicitação de Compras")

    // Fecha a tela após confirmar (OK)
    oView:SetCloseOnOK({|| .T.})
    
Return oView

User Function SZ3LEGND() 
    
    Local aLegenda := {} 
    
    aAdd(aLegenda,{"BR_VERDE", "Normal" })
    aAdd(aLegenda,{"BR_AZUL", "Preferencial"})
    aAdd(aLegenda,{"BR_LARANJA ", "Alta Prioridade"})
    aAdd(aLegenda,{"BR_VERMELHO ", "Urgente"})

    // Exibe a legenda visual
    BrwLegenda("Urgencia Pedidos","Normal/Preferencial/Alta Prioridade/Urgente",aLegenda)

Return aLegenda




