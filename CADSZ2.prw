#include 'Protheus.ch'
#include "FWMVCDEF.ch"

// ========================================================================================
// ==========================  Função principal do módulo CADSZ2 ==========================
// ========================================================================================

User Function CADSZ2()

    // Salva o ambiente atual para restaurar depois
    Local aArea := GetNextAlias()
    Local oBrowseSZ2 

    // Objeto responsável pelo Browse MVC
    oBrowseSZ2 := FwmBrowse():New()

    // Define a tabela principal do browse
    oBrowseSZ2:SetAlias("SZ2")

    // Descrição que aparece como título da tela
    oBrowseSZ2:SetDescription("Tela de Cadastro de Clientes Estacionamento")

    // Campos exibidos na listagem
    oBrowseSZ2:SetOnlyFields({"Z2_COD","Z2_NOME","Z2_CPF","Z2_MODVEIC","Z2_PLACVEI","Z2_TELEFON"})

     // Legendas visuais baseadas no status
    oBrowseSZ2:AddLegend("SZ2->Z2_STATUS == '1'", "RED", "CLIENTE ATIVO / N. PAGO")
    oBrowseSZ2:AddLegend("SZ2->Z2_STATUS == '2'", "GREEN", "CLIENTE ATIVO/ PAGO")
    oBrowseSZ2:AddLegend("SZ2->Z2_STATUS == '3'", "BLUE", "CLIENTE INATIVO")
    
    // Desabilita visualização de detalhes padrão
    oBrowseSZ2:DisableDetails()

    // Ativa a tela
    oBrowseSZ2:Activate()

    // Restaura o ambiente atual
    RestArea(aArea)

Return

/*
    -------------------------------------------------------------------------
    MenuDef()
    Define as opções do menu que serão exibidas no browse.
    -------------------------------------------------------------------------
*/
Static Function MenuDef()
    
    Local aRotina := {}
   
    ADD OPTION aRotina TITLE 'Visualizar' ACTION "VIEWDEF.CADSZ2" OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Incluir'    ACTION "VIEWDEF.CADSZ2" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'    ACTION "VIEWDEF.CADSZ2" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'    ACTION "VIEWDEF.CADSZ2" OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE 'Legenda'    ACTION "u_SZ2LEGND  "   OPERATION 6 ACCESS 0
    ADD OPTION aRotina TITLE 'Descrição'  ACTION "u_SZ2DESC  "    OPERATION 6 ACCESS 0
                      
Return aRotina

/*
    -------------------------------------------------------------------------
    ModelDef()
    Define o Model do MVC — responsável pela camada de dados.
    -------------------------------------------------------------------------
*/
Static Function ModelDef()

    Local oModel := Nil
    
    // Estrutura dos campos da tabela SZ2 (para o Model)
    Local oStructSZ2 := FwFormStruct(1,"SZ2")

    // Instancia um novo Model
    oModel := MPFormModel():New("CADSZ2M")

    // Adiciona a estrutura de campos ao model
    oModel:AddFields("FORMSZ2",Nil,oStructSZ2)

    // Define a chave primária da tabela
    oModel:SetPrimaryKey({"Z2_FILIAL","Z2_COD"})

    // Descrição geral do cadastro
    oModel:SetDescription("Cadastro de Clientes estacionamento")

    // Descrição do sub-modelo de formulário
    oModel:GetModel("FORMSZ2"):SetDescription("Modelo de dados do cadastro do estacionamento")

Return oModel

/*
    -------------------------------------------------------------------------
    ViewDef()
    Define a View do MVC — responsável pela camada visual.
    -------------------------------------------------------------------------
*/
Static Function ViewDef()
    
    Local oView := Nil

    // Carrega o Model definido anteriormente
    Local oModel := FwLoadModel("CADSZ2")

    // Estrutura visual (parâmetro 2 indica estrutura para View)
    Local oStructSZ2 := FwFormStruct(2,"SZ2")

    // Instancia a View     
    oView := FwFormView():New()

     // Associa o Model à View
    oView:SetModel(oModel)

    // Adiciona os campos à tela    
    oView:AddField("VIEWSZ2",oStructSZ2,"FORMSZ2")
    
    // Cria um container horizontal para organizar os campos
    oView:CreateHorizontalBox("TELASZ2",100)

    // Título da janela
    oView:EnableTitleView("VIEWSZ2","Vizualização dos Dados do Estacionamento") 
    
    // Fecha a janela ao confirmar a operação
    oView:SetCloseOnOk({||.T.})

    // Informa qual parte da View será exibida dentro do container
    oView:SetOwnerView("VIEWSZ2","TELASZ2")
       
Return oView


/*
    -------------------------------------------------------------------------
    SZ2LEGND()
    Exibe popup com as legendas usadas no browse.
    -------------------------------------------------------------------------
*/
User Function SZ2LEGND() 
    Local aLegenda := {} 
    aAdd(aLegenda,{"BR_VERMELHO", "Ativo / N. Pago"})
    aAdd(aLegenda,{"BR_VERDE", "Ativo / Pago"})
    aAdd(aLegenda,{"BR_AZUL", "Inativo"})

    BrwLegenda("Clientes Estacionamento","Ativos/Ativos Pagos/Inativos",aLegenda)

Return aLegenda

/*
    -------------------------------------------------------------------------
    SZ2DESC()
    Exibe uma mensagem com informações do desenvolvedor.
    -------------------------------------------------------------------------
*/
User Function SZ2DESC()
    Local cDesc

    cDesc := "-<b> Tela desenvolvida por <br> Antonio Marcos Zanotti."

    MsgInfo(cDesc)

Return
