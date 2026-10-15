setDefaultTab("Main")
HuntAnalyzer = HuntAnalyzer or {}
HuntAnalyzer.VERSAO = "3.0"

if HuntAnalyzer.janela then
    HuntAnalyzer.janela:destroy()
    HuntAnalyzer.janela = nil
end

local HA = HuntAnalyzer
storage.HuntAnalyzer = storage.HuntAnalyzer or {}
local cfg = storage.HuntAnalyzer
cfg.pos = cfg.pos or {x = 10, y = 120}
if cfg.repassar == nil then cfg.repassar = true end
cfg.sessoes = cfg.sessoes or {}
cfg.testes = cfg.testes or {}
cfg.duracaoTeste = cfg.duracaoTeste or 600
cfg.nomeTeste = cfg.nomeTeste or ""
cfg.bonus = cfg.bonus or {}
HA.POTION_PCT = 5
HA.MAX_POTIONS = 55
HA.DURACAO_POTION = 1800
HA.TABELA_POTIONS = {1, 5, 10, 20, 30, 40, 50, 55}
HA.MAX_TESTES = 10
HA.selecionados = {}

HA.COLUNAS_ITENS = 5
HA.AMOSTRA_S = 30
HA.MAX_AMOSTRAS = 31
HA.amostras = {}
HA.MAX_BICHOS_LISTA = 6
HA.mortos = {}
HA.mortosIds = {}
HA.MAX_DROPS_GUARDADOS = 50
HA.widgetsDrop = {}

local function nomeChar()
    local ok, n = pcall(function() return player:getName() end)
    return ok and n or "?"
end

function HA.novaSessao()
    return {seg = 0, xp = 0, niveis = 0, ouro = 0, lootValor = 0, kills = 0, loot = {}, nomes = {}, pausado = false}
end

function HA.sessao()
    local k = nomeChar()
    cfg.sessoes[k] = cfg.sessoes[k] or HA.novaSessao()
    local s = cfg.sessoes[k]
    s.loot = s.loot or {}
    s.nomes = s.nomes or {}
    s.niveis = s.niveis or 0
    s.bichos = s.bichos or {}
    return s
end

function HA.formatar(n)
    n = tonumber(n) or 0
    local a = math.abs(n)
    local txt
    if a < 1000 then
        txt = tostring(math.floor(n))
    elseif a < 1000000 then
        txt = string.format("%.1fK", n / 1000)
    elseif a < 1000000000 then
        txt = string.format("%.1fKK", n / 1000000)
    else
        txt = string.format("%.1fKKK", n / 1000000000)
    end
    return (txt:gsub("%.0(K+)$", "%1"))
end

function HA.formatarTempo(seg)
    seg = math.floor(seg or 0)
    return string.format("%02d:%02d:%02d", math.floor(seg / 3600), math.floor(seg % 3600 / 60), seg % 60)
end

function HA.porTempo(valor, s, segundos)
    if s.seg < 60 then return 0 end
    return valor * segundos / s.seg
end

function HA.porHora(valor, s)
    return HA.porTempo(valor, s, 3600)
end

function HA.recente(s, campo)
    local velha = HA.amostras[1]
    if not velha or s.seg - velha.seg < 60 then return nil end
    return (s[campo] - velha[campo]) * 3600 / (s.seg - velha.seg)
end

function HA.amostrar(s)
    local ultima = HA.amostras[#HA.amostras]
    if ultima and s.seg - ultima.seg < HA.AMOSTRA_S then return end
    table.insert(HA.amostras, {seg = s.seg, xp = s.xp, niveis = s.niveis})
    while #HA.amostras > HA.MAX_AMOSTRAS do table.remove(HA.amostras, 1) end
end

function HA.textoNiveis(v)
    if v >= 1 then return math.floor(v + 0.5) .. " lvl" end
    if v <= 0 then return "0 lvl" end
    local seg = math.floor(60 / v + 0.5)
    return "1 lvl a cada " .. math.floor(seg / 60) .. "m" .. string.format("%02d", seg % 60) .. "s"
end

local A = modules.game_analyser

HA.TOKEN_PADRAO = 100000000
function HA.valorToken()
    local ok, v = pcall(function() return tonumber(A.DMD_TOKEN_WORTH) end)
    return (ok and v and v > 0) and v or HA.TOKEN_PADRAO
end

function HA.tokens(gold)
    local t = (tonumber(gold) or 0) / HA.valorToken()
    return string.format(math.abs(t) < 1 and "%.3f" or "%.2f", t) .. " tk"
end

function HA.nivelAtual()
    local okL, lv = pcall(function() return player:getLevel() end)
    local okP, pct = pcall(function() return player:getLevelPercent() end)
    if not okL or not lv then return nil end
    return lv + ((okP and tonumber(pct)) or 0) / 100
end

function HA.preco(id)
    local ok, p = pcall(function() return A.DMD_PRECOS[id] end)
    return ok and tonumber(p) or 0
end

function HA.contando()
    return not HA.sessao().pausado
end

function HA.ehRastreado(nome)
    return tostring(nome or ""):lower():find("halloween", 1, true) ~= nil
end

function HA.tempoCurto(seg)
    seg = math.max(math.floor(seg or 0), 0)
    local h, m, sg = math.floor(seg / 3600), math.floor(seg % 3600 / 60), seg % 60
    if h > 0 then return h .. "h" .. string.format("%02d", m) .. "m" end
    return m .. "m" .. string.format("%02d", sg) .. "s"
end

function HA.textoDrop(s, k, nome, qtd, valor)
    local txt = nome .. " x" .. qtd .. " = " .. HA.tokens(valor)
    local drops = s.drops and s.drops[k]
    if not drops or #drops == 0 then return txt end
    txt = txt .. "\nDropou " .. qtd .. " em " .. HA.tempoCurto(s.seg)
    txt = txt .. "\nMedia: 1 a cada " .. HA.tempoCurto(s.seg / qtd)
    txt = txt .. "\nUltimo: ha " .. HA.tempoCurto(s.seg - drops[#drops])
    local tempos = {}
    for i = math.max(1, #drops - 9), #drops do table.insert(tempos, HA.tempoCurto(drops[i])) end
    return txt .. "\nDrops em: " .. table.concat(tempos, ", ")
end

function HA.aoLoot(item, nome, qtd)
    if not HA.contando() then return end
    local id = item:getId()
    qtd = tonumber(qtd) or 1
    local s = HA.sessao()
    local k = tostring(id)
    s.loot[k] = (s.loot[k] or 0) + qtd
    s.nomes[k] = nome or k
    s.lootValor = s.lootValor + HA.preco(id) * qtd
    if HA.ehRastreado(nome) then
        s.drops = s.drops or {}
        s.drops[k] = s.drops[k] or {}
        for _ = 1, qtd do table.insert(s.drops[k], s.seg) end
        while #s.drops[k] > HA.MAX_DROPS_GUARDADOS do table.remove(s.drops[k], 1) end
    end
    HA.lootMudou = true
    HA.dadosServidor = true
end

function HA.aoOuro(valor)
    if not HA.contando() then return end
    local s = HA.sessao()
    s.ouro = s.ouro + (tonumber(valor) or 0)
    HA.dadosServidor = true
end

function HA.nomeDoMorto()
    local agora = now
    while HA.mortos[1] and agora - HA.mortos[1].t > 3000 do table.remove(HA.mortos, 1) end
    local m = table.remove(HA.mortos, 1)
    if m then return m.nome end
    if HA.ultimoMorto and agora - HA.ultimoMorto.t < 30000 then return HA.ultimoMorto.nome end
    return nil
end

function HA.aoXpBicho(xp)
    if not HA.contando() or not xp or xp <= 0 then return end
    local s = HA.sessao()
    local nome = (HA.nomeDoMorto() or "Desconhecido"):gsub("^Demolisher ", "")
    s.bichos[nome] = s.bichos[nome] or {n = 0, xp = 0}
    s.bichos[nome].n = s.bichos[nome].n + 1
    s.bichos[nome].xp = s.bichos[nome].xp + xp
    s.atual = {nome = nome, xp = xp}
    HA.bichosMudou = true
end

if onCreatureHealthPercentChange then
    onCreatureHealthPercentChange(function(c, hp)
        if not hp or hp > 0 then return end
        local okM, ehMonstro = pcall(function() return c:isMonster() end)
        local okI, id = pcall(function() return c:getId() end)
        if not okM or not ehMonstro or not okI or HA.mortosIds[id] then return end
        HA.mortosIds[id] = now
        table.insert(HA.mortos, {nome = c:getName(), t = now})
        HA.ultimoMorto = {nome = c:getName(), t = now}
        while #HA.mortos > 30 do table.remove(HA.mortos, 1) end
    end)
end

function HA.bonusChar()
    local k = nomeChar()
    cfg.bonus[k] = cfg.bonus[k] or {potions = 0}
    return cfg.bonus[k]
end

function HA.aoActivityBonus(txt)
    local v = tonumber((txt:gsub(",", ".")))
    if not v then return end
    local b = HA.bonusChar()
    b.activity = v
    b.lidoEm = os.time()
end

function HA.aoUsarPotions(qtd)
    local n = tonumber(qtd)
    if not n then return end
    local b = HA.bonusChar()
    b.potions = math.max(0, math.min(HA.MAX_POTIONS, math.floor(n)))
    b.usadasEm = os.time()
    if HA.atualizarCampoPotions then HA.atualizarCampoPotions() end
end

function HA.checarFimPotions()
    local b = HA.bonusChar()
    if not b.usadasEm or os.time() - b.usadasEm < HA.DURACAO_POTION then return end
    b.potions = 0
    b.usadasEm = nil
    if HA.atualizarCampoPotions then HA.atualizarCampoPotions() end
end

onTextMessage(function(mode, text)
    local t = tostring(text or "")
    local n = t:match("[Yy]ou gained (%d+) experience point")
    if n then pcall(HA.aoXpBicho, tonumber(n)) return end
    local ab = t:match("([%d%.,]+)%%%s*de Activity Bonus") or t:match("([%d%.,]+)%%%s*Activity Bonus")
    if ab then pcall(HA.aoActivityBonus, ab) return end
    local usadas = t:match("[Uu]sou (%d+) po[^%s]* de XP")
    if usadas then pcall(HA.aoUsarPotions, usadas) end
end)

macro(60000, function()
    for id, t in pairs(HA.mortosIds) do
        if now - t > 60000 then HA.mortosIds[id] = nil end
    end
end)

function HA.aoKill()
    if not HA.contando() then return end
    local s = HA.sessao()
    s.kills = s.kills + 1
    HA.dadosServidor = true
end

function HA.conectar()
    if type(A) ~= "table" then return false end
    local okF, temLoot = pcall(function() return type(A.onLootStats) == "function" end)
    if not okF or not temLoot then return false end
    if not A.huntAnalyzerOrig then
        A.huntAnalyzerOrig = {
            onLootStats = A.onLootStats,
            onSupplyTracker = A.onSupplyTracker,
            onImpactTracker = A.onImpactTracker,
            onKillTracker = A.onKillTracker,
            ouroHunting = A.HuntingAnalyser and A.HuntingAnalyser.dmdAddGold,
            ouroLoot = A.LootAnalyser and A.LootAnalyser.dmdAddGold,
        }
    end
    local O = A.huntAnalyzerOrig
    A.onLootStats = function(item, nome, qtd)
        pcall(HA.aoLoot, item, nome, qtd)
        if cfg.repassar and O.onLootStats then return O.onLootStats(item, nome, qtd) end
    end
    A.onSupplyTracker = function(id)
        if cfg.repassar and O.onSupplyTracker then return O.onSupplyTracker(id) end
    end
    A.onImpactTracker = function(tipo, valor, efeito, alvo)
        if cfg.repassar and O.onImpactTracker then return O.onImpactTracker(tipo, valor, efeito, alvo) end
    end
    A.onKillTracker = function(nome, outfit, drops)
        pcall(HA.aoKill)
        if cfg.repassar and O.onKillTracker then return O.onKillTracker(nome, outfit, drops) end
    end
    if A.HuntingAnalyser then
        A.HuntingAnalyser.dmdAddGold = function(self, valor)
            pcall(HA.aoOuro, valor)
            if cfg.repassar and O.ouroHunting then return O.ouroHunting(self, valor) end
        end
    end
    if A.LootAnalyser then
        A.LootAnalyser.dmdAddGold = function(self, valor)
            if cfg.repassar and O.ouroLoot then return O.ouroLoot(self, valor) end
        end
    end
    return true
end

HA.conectado = HA.conectar()

g_ui.importStyleFromString([[
HABtn < UIButton
  font: verdana-11px-rounded
  text-align: center
  background-color: #2A2A2AEE
  border-width: 1
  border-color: #5A5A5A
  color: #DDDDDD
  height: 18
  $hover:
    background-color: #3D3D3DEE
    border-color: #8A8A8A
  $pressed:
    background-color: #151515EE

HASecao < UILabel
  height: 18
  font: verdana-11px-rounded
  text-offset: 6 0
  color: #FFFFFF
  background-color: #1E2A3AEE
  border-width: 1
  border-color: #33475E
  margin-top: 4

HALinha < Panel
  height: 15
  UILabel
    id: nome
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    font: verdana-11px-rounded
    color: #CCCCCC
    text-auto-resize: true
  UILabel
    id: valor
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    font: verdana-11px-rounded
    color: #FFFFFF
    text-auto-resize: true

HAResultado < UIButton
  height: 16
  font: verdana-11px-rounded
  text-align: left
  text-offset: 4 0
  color: #CCCCCC
  background-color: #1A1A1AEE
  border-width: 1
  border-color: #333333
  $hover:
    border-color: #8A8A8A

HAComp < Panel
  height: 15
  UILabel
    id: rotulo
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: 62
    font: verdana-11px-rounded
    color: #CCCCCC
  UILabel
    id: a
    anchors.left: rotulo.right
    anchors.verticalCenter: parent.verticalCenter
    width: 60
    font: verdana-11px-rounded
    text-align: right
    color: #FFFFFF
  UILabel
    id: b
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    width: 60
    font: verdana-11px-rounded
    text-align: right
    color: #FFFFFF

HAResumo < UILabel
  font: verdana-11px-rounded
  color: #DDDDDD
  text-wrap: true
  text-auto-resize: true
  margin-top: 3

HAItem < UIItem
  size: 32 32
  virtual: true
  UILabel
    id: qtd
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    font: verdana-11px-rounded
    color: #FFFFFF
    text-auto-resize: true

HuntAnalyzerWindow < UIWindow
  width: 196
  height: 400
  padding: 6
  image-source: ~
  background-color: #0B0B0BF0
  border-width: 1
  border-color: #5A5A5A
  @onEscape: self:hide()

  Panel
    id: header
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 18
    UILabel
      id: tituloVersao
      color: #6BB6FF
      font: verdana-11px-rounded
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text-auto-resize: true
    HABtn
      id: closeButton
      text: X
      anchors.right: parent.right
      anchors.top: parent.top
      size: 20 18
      color: #FF5555

  Panel
    id: corpo
    anchors.top: header.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    layout:
      type: verticalBox
      spacing: 1
      fit-children: true
    Panel
      height: 18
      layout:
        type: horizontalBox
        spacing: 2
      HABtn
        id: abaHunt
        text: HUNT
        width: 60
      HABtn
        id: abaTestes
        text: TESTES
        width: 60
      HABtn
        id: abaPotions
        text: POTIONS
        width: 60
    Panel
      id: paginaHunt
      layout:
        type: verticalBox
        spacing: 1
        fit-children: true
      HASecao
        id: sSessao
        text: Sessao
        HABtn
          id: min
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          margin-right: 1
          size: 16 14
      Panel
        id: linhaRelogio
        height: 24
        UILabel
          id: relogio
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          font: sans-bold-16px
          color: #4AA3FF
          text-auto-resize: true
        HABtn
          id: zerar
          text: Zerar
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          width: 44
        HABtn
          id: pausar
          anchors.right: zerar.left
          anchors.verticalCenter: parent.verticalCenter
          margin-right: 3
          width: 54
      HALinha
        id: lLucro
      HALinha
        id: lLucroHora
      HALinha
        id: lKills
      HASecao
        id: sBichos
        text: XP por bicho
        HABtn
          id: min
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          margin-right: 1
          size: 16 14
      HALinha
        id: lAtual
      Panel
        id: listaBichos
        height: 0
        layout:
          type: verticalBox
          spacing: 1
          fit-children: true
      HASecao
        id: sSaques
        text: Saques
        HABtn
          id: min
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          margin-right: 1
          size: 16 14
      Panel
        id: itens
        height: 0
        margin-top: 2
        layout:
          type: grid
          cell-size: 34 34
          cell-spacing: 2
          flow: true
      HASecao
        id: sExp
        text: Experiencia
        HABtn
          id: min
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          margin-right: 1
          size: 16 14
      HALinha
        id: lXp
      HALinha
        id: lXpMin
      HALinha
        id: lXp10
      HALinha
        id: lXpHora
      HALinha
        id: lXp15
      HALinha
        id: lNiv
      HALinha
        id: lNivMin
      HALinha
        id: lNiv10
      HALinha
        id: lNivHora
      HALinha
        id: lNiv15
      HALinha
        id: lProxNivel
    Panel
      id: paginaTestes
      visible: false
      layout:
        type: verticalBox
        spacing: 1
        fit-children: true
      HASecao
        text: Teste de hunt
      Panel
        height: 18
        margin-top: 2
        layout:
          type: horizontalBox
          spacing: 2
        HABtn
          id: t10
          text: 10m
          width: 30
        HABtn
          id: t20
          text: 20m
          width: 30
        HABtn
          id: t30
          text: 30m
          width: 30
        TextEdit
          id: tMinutos
          width: 40
          height: 18
          font: verdana-11px-rounded
        UILabel
          text: min
          width: 40
          font: verdana-11px-rounded
          color: #CCCCCC
          text-offset: 2 3
      HABtn
        id: tIniciar
        margin-top: 2
      TextEdit
        id: tNome
        height: 18
        margin-top: 2
        font: verdana-11px-rounded
      UILabel
        id: tStatus
        height: 14
        font: verdana-11px-rounded
        color: #FFD24A
      Panel
        id: listaTestes
        height: 0
        layout:
          type: verticalBox
          spacing: 1
          fit-children: true
      Panel
        id: comparacao
        height: 0
        margin-top: 2
        layout:
          type: verticalBox
          spacing: 1
          fit-children: true
      HABtn
        id: tApagar
        text: Apagar selecionados
        margin-top: 2
    Panel
      id: paginaPotions
      visible: false
      layout:
        type: verticalBox
        spacing: 1
        fit-children: true
      HASecao
        text: Bonus de XP
      HALinha
        id: lActivity
      HABtn
        id: pLerBonus
        text: Ler !bonusxp
        margin-top: 2
      Panel
        height: 18
        margin-top: 2
        UILabel
          text: Potions ativas
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          font: verdana-11px-rounded
          color: #CCCCCC
          text-auto-resize: true
        TextEdit
          id: pQtd
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          width: 40
          height: 18
          font: verdana-11px-rounded
      HALinha
        id: lPotBonus
      HALinha
        id: lTotalBonus
      HASecao
        text: Ganho das potions
      HALinha
        id: lPotXpBase
      HALinha
        id: lPotSem
      HALinha
        id: lPotAgora
      Panel
        id: listaPotions
        layout:
          type: verticalBox
          spacing: 1
          fit-children: true
      UILabel
        id: pAviso
        height: 14
        font: verdana-11px-rounded
        color: #888888
    HABtn
      id: repassar
      margin-top: 6
    UILabel
      id: status
      height: 14
      font: verdana-11px-rounded
      color: #888888
]])

local w = g_ui.createWidget("HuntAnalyzerWindow", g_ui.getRootWidget())
HA.janela = w
w:setPosition({x = cfg.pos.x, y = cfg.pos.y})
w:hide()
w.onMove = function(widget, newPos) cfg.pos = {x = newPos.x, y = newPos.y} end

local function el(id) return w:recursiveGetChildById(id) end
el("tituloVersao"):setText("HUNT ANALYZER " .. HA.VERSAO)

local function linha(id, nome, cor)
    local l = el(id)
    l:getChildById("nome"):setText(nome)
    if cor then l:getChildById("valor"):setColor(cor) end
    return l:getChildById("valor")
end

local ui = {
    relogio = el("relogio"), pausar = el("pausar"), zerar = el("zerar"), itens = el("itens"),
    repassar = el("repassar"), status = el("status"), corpo = el("corpo"),
    t10 = el("t10"), t20 = el("t20"), t30 = el("t30"), tIniciar = el("tIniciar"), tNome = el("tNome"), tMinutos = el("tMinutos"),
    tStatus = el("tStatus"), listaTestes = el("listaTestes"), comparacao = el("comparacao"), tApagar = el("tApagar"),
    abaHunt = el("abaHunt"), abaTestes = el("abaTestes"), paginaHunt = el("paginaHunt"), paginaTestes = el("paginaTestes"),
    lucro = linha("lLucro", "Lucro", "#55DD55"),
    lucroHora = linha("lLucroHora", "Lucro por hora", "#55DD55"),
    kills = linha("lKills", "Derrotados"),
    atual = linha("lAtual", "Atual", "#77FF77"),
    listaBichos = el("listaBichos"),
    xp = linha("lXp", "XP total"),
    xpMin = linha("lXpMin", "XP por minuto"),
    xp10 = linha("lXp10", "XP a cada 10 min"),
    xpHora = linha("lXpHora", "XP por hora"),
    xp15 = linha("lXp15", "XP hora (ult. 15 min)", "#6BB6FF"),
    niv = linha("lNiv", "Lvl ganhos", "#FFD24A"),
    nivMin = linha("lNivMin", "Lvl min", "#FFD24A"),
    niv10 = linha("lNiv10", "Lvl 10 min", "#FFD24A"),
    nivHora = linha("lNivHora", "Lvl hora", "#FFD24A"),
    niv15 = linha("lNiv15", "Lvl hora (ult. 15 min)", "#6BB6FF"),
    proxNivel = linha("lProxNivel", "Prox. nivel em"),
    abaPotions = el("abaPotions"), paginaPotions = el("paginaPotions"),
    pLerBonus = el("pLerBonus"), pQtd = el("pQtd"), listaPotions = el("listaPotions"), pAviso = el("pAviso"),
    activity = linha("lActivity", "Activity Bonus", "#FFD24A"),
    potBonus = linha("lPotBonus", "Potions", "#77FF77"),
    totalBonus = linha("lTotalBonus", "Activity x Potions", "#6BB6FF"),
    potXpBase = linha("lPotXpBase", "XP hora medida"),
    potSem = linha("lPotSem", "Sem potion", "#AAAAAA"),
    potAgora = linha("lPotAgora", "Agora", "#FFD24A"),
}

HA.linhasPotions = {}
for _, k in ipairs(HA.TABELA_POTIONS) do
    local l = g_ui.createWidget("HALinha", ui.listaPotions)
    l:getChildById("nome"):setText(k .. (k == 1 and " potion" or " potions"))
    l:getChildById("valor"):setColor("#77FF77")
    table.insert(HA.linhasPotions, {k = k, valor = l:getChildById("valor")})
end

function HA.ajustarAltura()
    HA.medirAltura()
    schedule(20, HA.medirAltura)
end

function HA.medirAltura()
    pcall(function() ui.paginaHunt:getLayout():update() end)
    pcall(function() ui.paginaTestes:getLayout():update() end)
    pcall(function() ui.listaPotions:getLayout():update() end)
    pcall(function() ui.paginaPotions:getLayout():update() end)
    pcall(function() ui.corpo:getLayout():update() end)
    w:setHeight(ui.corpo:getHeight() + 30)
end

function HA.cortar(txt, max)
    if #txt <= max then return txt end
    return txt:sub(1, max - 1) .. "."
end

function HA.atualizarBichos()
    HA.bichosMudou = false
    local s = HA.sessao()
    local function mostrar(widget, b, rotulo)
        widget:getParent():getChildById("nome"):setText(rotulo .. (b and (": " .. HA.cortar(b.nome, 16)) or ""))
        widget:setText(b and HA.formatar(b.xp) or "--")
    end
    mostrar(ui.atual, s.atual, "Atual")
    ui.listaBichos:destroyChildren()
    local lista = {}
    for nome, b in pairs(s.bichos) do table.insert(lista, {nome = nome, n = b.n, xp = b.xp}) end
    table.sort(lista, function(a, b) return a.n > b.n end)
    for i, b in ipairs(lista) do
        if i > HA.MAX_BICHOS_LISTA then break end
        local l = g_ui.createWidget("HALinha", ui.listaBichos)
        l:getChildById("nome"):setText(HA.cortar(b.nome, 16))
        l:getChildById("valor"):setText(b.n .. "x  " .. HA.formatar(b.xp / b.n))
        l:getChildById("valor"):setColor("#6BB6FF")
    end
    HA.ajustarAltura()
end

function HA.atualizarItens()
    HA.lootMudou = false
    local s = HA.sessao()
    ui.itens:destroyChildren()
    HA.widgetsDrop = {}
    local lista = {}
    for k, qtd in pairs(s.loot) do
        table.insert(lista, {id = tonumber(k), qtd = qtd, nome = s.nomes[k] or k})
    end
    table.sort(lista, function(a, b) return a.qtd * HA.preco(a.id) > b.qtd * HA.preco(b.id) end)
    for _, it in ipairs(lista) do
        local wi = g_ui.createWidget("HAItem", ui.itens)
        pcall(function() wi:setItemId(it.id) end)
        wi:getChildById("qtd"):setText(HA.formatar(it.qtd))
        local k = tostring(it.id)
        wi:setTooltip(HA.textoDrop(s, k, it.nome, it.qtd, it.qtd * HA.preco(it.id)))
        if s.drops and s.drops[k] then HA.widgetsDrop[k] = {w = wi, nome = it.nome} end
    end
    local linhas = math.ceil(#lista / HA.COLUNAS_ITENS)
    ui.itens:setHeight(linhas * 36)
    HA.ajustarAltura()
end

function HA.proximoNivel(s)
    local xpHora = HA.porHora(s.xp, s)
    if xpHora <= 0 then return "--" end
    local ok, falta = pcall(function()
        return modules.game_skills.expForLevel(player:getLevel() + 1) - player:getExperience()
    end)
    if not ok or not falta or falta <= 0 then return "--" end
    return HA.formatarTempo(falta / xpHora * 3600)
end

function HA.testes()
    local k = nomeChar()
    cfg.testes[k] = cfg.testes[k] or {}
    return cfg.testes[k]
end

function HA.copiarContagem(bichos)
    local c = {}
    for nome, b in pairs(bichos) do c[nome] = b.n end
    return c
end

function HA.resetAtual()
    local ok, r = pcall(function() return player:getReset() end)
    if ok and tonumber(r) then return tonumber(r) end
    ok, r = pcall(function() return A.DMD_RESETS end)
    if ok and tonumber(r) then return tonumber(r) end
    return 0
end

function HA.textoInicio(r)
    if not r.lvl then return "--" end
    return "Reset " .. (r.reset or 0) .. " Lv " .. r.lvl
end

function HA.zerarSessao()
    cfg.sessoes[nomeChar()] = HA.novaSessao()
    local okX, xp = pcall(function() return player:getExperience() end)
    HA.ultimaXp = okX and xp or nil
    HA.ultimoNivel = HA.nivelAtual()
    HA.amostras = {}
    HA.lootMudou = true
    HA.bichosMudou = true
end

function HA.iniciarTeste()
    HA.zerarSessao()
    local s = HA.sessao()
    local nome = ui.tNome:getText():gsub("^%s+", ""):gsub("%s+$", "")
    local okL, lvl = pcall(function() return player:getLevel() end)
    s.teste = {dur = cfg.duracaoTeste, nome = nome, seg0 = s.seg, xp0 = s.xp, niv0 = s.niveis,
        lvl = okL and lvl or nil, reset = HA.resetAtual(),
        lucro0 = s.lootValor + s.ouro, kills0 = s.kills, bichos0 = HA.copiarContagem(s.bichos)}
    s.pausado = false
    ui.tStatus:setText("")
end

function HA.terminarTeste(s)
    local t = s.teste
    s.teste = nil
    local seg = s.seg - t.seg0
    if seg < 30 then
        ui.tStatus:setText("Teste cancelado (menos de 30s).")
        return
    end
    local nome = t.nome
    if not nome or nome == "" then
        local melhor, melhorN = "Hunt", 0
        for nomeB, b in pairs(s.bichos) do
            local n = b.n - ((t.bichos0 or {})[nomeB] or 0)
            if n > melhorN then melhor, melhorN = nomeB, n end
        end
        nome = melhor
    end
    local r = {nome = nome, seg = seg, xp = s.xp - t.xp0, niveis = s.niveis - t.niv0,
        lucro = s.lootValor + s.ouro - t.lucro0, kills = s.kills - t.kills0,
        quando = os.date("%d/%m %H:%M"), parcial = seg < t.dur, dur = t.dur, lvl = t.lvl, reset = t.reset}
    local lista = HA.testes()
    table.insert(lista, 1, r)
    while #lista > HA.MAX_TESTES do table.remove(lista) end
    HA.selecionados = {1}
    HA.testesMudou = true
    ui.tStatus:setText("Teste salvo: " .. HA.cortar(nome, 18))
    print("[Hunt Analyzer] Teste de " .. math.floor(seg / 60) .. " min terminado: " .. nome)
end

function HA.checarTeste(s)
    if s.teste and s.seg - s.teste.seg0 >= s.teste.dur then HA.terminarTeste(s) end
end

function HA.porHoraTeste(r, campo)
    return r[campo] * 3600 / math.max(r.seg, 1)
end

HA.METRICAS = {
    {rotulo = "XP/h", valor = function(r) return HA.porHoraTeste(r, "xp") end, texto = HA.formatar},
    {rotulo = "Lvl/h", valor = function(r) return HA.porHoraTeste(r, "niveis") end,
        texto = function(v) return math.floor(v + 0.5) .. " lvl" end},
    {rotulo = "Lucro/h", valor = function(r) return HA.porHoraTeste(r, "lucro") end,
        texto = function(v) return HA.tokens(v) end},
    {rotulo = "Bichos/h", valor = function(r) return HA.porHoraTeste(r, "kills") end,
        texto = function(v) return tostring(math.floor(v + 0.5)) end},
    {rotulo = "XP/bicho", valor = function(r) return r.xp / math.max(r.kills, 1) end, texto = HA.formatar},
}

function HA.textoComp(txt)
    local l = g_ui.createWidget("UILabel", ui.comparacao)
    l:setHeight(14)
    l:setFont("verdana-11px-rounded")
    l:setColor("#AAAAAA")
    l:setText(txt)
end

function HA.linhaComp(rotulo, a, b, corA, corB)
    local l = g_ui.createWidget("HAComp", ui.comparacao)
    l:getChildById("rotulo"):setText(rotulo)
    l:getChildById("a"):setText(a)
    l:getChildById("b"):setText(b)
    if corA then l:getChildById("a"):setColor(corA) end
    if corB then l:getChildById("b"):setColor(corB) end
end

function HA.pct(a, b)
    if not b or b <= 0 then return nil end
    return math.floor((a - b) / b * 100 + 0.5)
end

HA.COR_TEXTO = "#DDDDDD"
HA.COR_NOME = "#FFD24A"
HA.COR_MELHOR = "#55DD55"
HA.COR_PIOR = "#FF5555"

function HA.motivo(add, maisBichos, maisPorBicho, pk, pb, oque)
    local function pct(p)
        if p then
            add(" (")
            add("+" .. p .. "%", HA.COR_MELHOR)
            add(")")
        end
    end
    if maisBichos and maisPorBicho then
        add(" Matou ")
        add("mais bichos por hora", HA.COR_MELHOR)
        pct(pk)
        add(" e cada bicho deu ")
        add("mais " .. oque, HA.COR_MELHOR)
        pct(pb)
        add(".")
    elseif maisBichos then
        add(" Matou ")
        add("mais bichos por hora", HA.COR_MELHOR)
        pct(pk)
        add(", mesmo cada bicho dando ")
        add("menos " .. oque, HA.COR_PIOR)
        add(".")
    elseif maisPorBicho then
        add(" Cada bicho deu ")
        add("mais " .. oque, HA.COR_MELHOR)
        pct(pb)
        add(", mesmo matando ")
        add("menos bichos por hora", HA.COR_PIOR)
        add(".")
    end
end

function HA.explicar(ra, rb)
    local partes = {}
    local function add(txt, cor)
        table.insert(partes, txt)
        table.insert(partes, cor or HA.COR_TEXTO)
    end
    local nomes = {}
    nomes[ra] = HA.cortar(ra.nome, 14)
    nomes[rb] = HA.cortar(rb.nome, 14)
    if nomes[ra] == nomes[rb] then
        nomes[ra] = nomes[ra] .. " (1)"
        nomes[rb] = nomes[rb] .. " (2)"
    end
    local function porBicho(r, campo) return r[campo] / math.max(r.kills, 1) end
    local function comparar(titulo, campo, fmt)
        local va, vb = HA.porHoraTeste(ra, campo), HA.porHoraTeste(rb, campo)
        add(titulo .. ": ")
        if va == vb then
            add("empate.")
            return nil, nil
        end
        local w, l, vw, vl = ra, rb, va, vb
        if vb > va then w, l, vw, vl = rb, ra, vb, va end
        local p = HA.pct(vw, vl)
        add(nomes[w], HA.COR_NOME)
        add(" melhor")
        if p then
            add(" (")
            add("+" .. p .. "%", HA.COR_MELHOR)
            add(")")
        end
        add(", ")
        add(fmt(vw), HA.COR_MELHOR)
        add(" x ")
        add(fmt(vl), HA.COR_PIOR)
        add(".")
        return w, l
    end
    local function paragrafo()
        if #partes > 0 then add("\n\n") end
    end

    local w, l = comparar("XP/h", "xp", HA.formatar)
    if w then
        local kw, kl = HA.porHoraTeste(w, "kills"), HA.porHoraTeste(l, "kills")
        local bw, bl = porBicho(w, "xp"), porBicho(l, "xp")
        HA.motivo(add, kw > kl, bw > bl, HA.pct(kw, kl), HA.pct(bw, bl), "XP")
    end

    paragrafo()
    w, l = comparar("Lvl/h", "niveis", function(v) return math.floor(v + 0.5) .. " lvl" end)
    if w then
        if w.lvl and l.lvl and w.lvl < l.lvl then
            add(" Comecou em ")
            add("level menor", HA.COR_MELHOR)
            add(" (Lv ")
            add(tostring(w.lvl), HA.COR_MELHOR)
            add(" x Lv ")
            add(tostring(l.lvl), HA.COR_PIOR)
            add("): cada level custa menos XP.")
        elseif HA.porHoraTeste(w, "xp") > HA.porHoraTeste(l, "xp") then
            add(" Fez ")
            add("mais XP por hora", HA.COR_MELHOR)
            add(".")
        end
    end

    paragrafo()
    w, l = comparar("Lucro/h", "lucro", HA.tokens)
    if w then
        local kw, kl = HA.porHoraTeste(w, "kills"), HA.porHoraTeste(l, "kills")
        local bw, bl = porBicho(w, "lucro"), porBicho(l, "lucro")
        HA.motivo(add, kw > kl, bw > bl, HA.pct(kw, kl), HA.pct(bw, bl), "loot")
    end

    if (ra.reset or 0) ~= (rb.reset or 0) then
        paragrafo()
        add("Obs: resets diferentes (Reset " .. (ra.reset or 0) .. " x Reset " .. (rb.reset or 0) .. ").")
    end
    for _, r in ipairs({ra, rb}) do
        if r.seg < 300 then
            paragrafo()
            add("Obs: ")
            add(nomes[r], HA.COR_NOME)
            add(" durou so ")
            add(HA.formatarTempo(r.seg), HA.COR_PIOR)
            add(", resultado menos confiavel.")
        end
    end
    return partes
end

function HA.textoDasPartes(partes)
    local t = {}
    for i = 1, #partes, 2 do table.insert(t, partes[i]) end
    return table.concat(t)
end

function HA.atualizarTestes()
    HA.testesMudou = false
    local lista = HA.testes()
    ui.listaTestes:destroyChildren()
    local sel = {}
    for _, i in ipairs(HA.selecionados) do sel[i] = true end
    for i, r in ipairs(lista) do
        local b = g_ui.createWidget("HAResultado", ui.listaTestes)
        b:setText(HA.cortar(r.nome, 9) .. " " .. math.floor(r.seg / 60) .. "m" .. (r.parcial and "*" or "") ..
            " " .. HA.textoInicio(r))
        b:setTooltip(r.quando .. " | inicio " .. HA.textoInicio(r) .. " | " .. HA.formatarTempo(r.seg) ..
            (r.parcial and (" de " .. math.floor((r.dur or r.seg) / 60) .. " min (parado antes)") or "") ..
            "\nXP " .. HA.formatar(r.xp) .. " | " .. math.floor(r.niveis) .. " lvl | lucro " .. HA.tokens(r.lucro) ..
            " | " .. r.kills .. " bichos")
        if sel[i] then
            b:setBackgroundColor("#3A3000EE")
            b:setColor("#FFD24A")
        end
        b.onClick = function()
            local nova = {}
            local estava = false
            for _, j in ipairs(HA.selecionados) do
                if j == i then estava = true else table.insert(nova, j) end
            end
            if not estava then
                table.insert(nova, i)
                while #nova > 2 do table.remove(nova, 1) end
            end
            HA.selecionados = nova
            HA.testesMudou = true
            HA.atualizarPainel()
        end
    end
    ui.comparacao:destroyChildren()
    local ra, rb = lista[HA.selecionados[1] or 0], lista[HA.selecionados[2] or 0]
    if #lista == 0 then
        HA.textoComp("Nenhum teste salvo ainda.")
    elseif not (ra and rb) then
        HA.textoComp("Clique em 2 testes pra comparar.")
    else
        HA.linhaComp("", HA.cortar(ra.nome, 9), HA.cortar(rb.nome, 9), "#FFD24A", "#FFD24A")
        local vitA, vitB = 0, 0
        for _, m in ipairs(HA.METRICAS) do
            local va, vb = m.valor(ra), m.valor(rb)
            local corA, corB
            if va > vb then
                corA, vitA = "#55DD55", vitA + 1
            elseif vb > va then
                corB, vitB = "#55DD55", vitB + 1
            end
            HA.linhaComp(m.rotulo, m.texto(va), m.texto(vb), corA, corB)
        end
        HA.linhaComp("Reset", tostring(ra.reset or "--"), tostring(rb.reset or "--"))
        HA.linhaComp("Lv", tostring(ra.lvl or "--"), tostring(rb.lvl or "--"))
        HA.linhaComp("Duracao", HA.formatarTempo(ra.seg), HA.formatarTempo(rb.seg))
        local vencedor = vitA > vitB and ra.nome or (vitB > vitA and rb.nome or "empate")
        HA.linhaComp("Melhor:", HA.cortar(vencedor, 9), vitA .. " x " .. vitB, "#55DD55", "#AAAAAA")
        local resumo = g_ui.createWidget("HAResumo", ui.comparacao)
        local partes = HA.explicar(ra, rb)
        if not pcall(function() resumo:setColoredText(partes) end) then
            resumo:setText(HA.textoDasPartes(partes))
        end
    end
    HA.ajustarAltura()
end

function HA.pintarTeste()
    local s = HA.sessao()
    for _, d in ipairs({{ui.t10, 600}, {ui.t20, 1200}, {ui.t30, 1800}}) do
        local escolhido = cfg.duracaoTeste == d[2] and not s.teste
        d[1]:setColor(escolhido and "#FFD24A" or "#888888")
        d[1]:setBackgroundColor(escolhido and "#3A3000EE" or "#2A2A2AEE")
    end
    if s.teste then
        local falta = s.teste.dur - (s.seg - s.teste.seg0)
        ui.tIniciar:setText("Parar teste")
        ui.tIniciar:setColor("#FF8888")
        ui.tStatus:setText("Testando: falta " .. HA.formatarTempo(math.max(falta, 0)) .. (s.pausado and " (pausado)" or ""))
    else
        ui.tIniciar:setText("Iniciar teste")
        ui.tIniciar:setColor("#77FF77")
        if ui.tStatus:getText() == "" then ui.tStatus:setText("Nome da hunt (opcional) acima") end
    end
end

function HA.textoLvl(v)
    return string.format(v < 10 and "%.1f" or "%.0f", v) .. " lvl"
end

function HA.mostrarAviso(txt)
    local visivel = txt ~= ""
    ui.pAviso:setText(txt)
    if HA.avisoVisivel ~= visivel then
        HA.avisoVisivel = visivel
        ui.pAviso:setVisible(visivel)
        HA.ajustarAltura()
    end
end

function HA.atualizarPotions()
    local s = HA.sessao()
    local b = HA.bonusChar()
    local n = math.max(0, math.min(HA.MAX_POTIONS, math.floor(tonumber(b.potions) or 0)))
    local potMult = 1 + n * HA.POTION_PCT / 100
    if b.activity then
        ui.activity:setText(string.format("%.2f%%", b.activity))
        ui.activity:setTooltip("Lido do !bonusxp ha " .. HA.tempoCurto(os.time() - (b.lidoEm or os.time())))
        ui.totalBonus:setText(string.format("x%.2f", (1 + b.activity / 100) * potMult))
    else
        ui.activity:setText("use !bonusxp")
        ui.totalBonus:setText("--")
    end
    local fim = b.usadasEm and (" (" .. HA.tempoCurto(HA.DURACAO_POTION - (os.time() - b.usadasEm)) .. ")") or ""
    ui.potBonus:setText("+" .. n * HA.POTION_PCT .. "%" .. fim)
    ui.potAgora:getParent():getChildById("nome"):setText("Agora (" .. n .. " pot)")
    local xpHora = HA.recente(s, "xp") or HA.porHora(s.xp, s)
    local lvlPorXp = (s.xp > 0 and s.niveis > 0) and s.niveis / s.xp or nil
    local function texto(xp, sinal)
        sinal = sinal or ""
        local t = sinal .. HA.formatar(xp)
        if lvlPorXp then t = t .. "  " .. sinal .. HA.textoLvl(xp * lvlPorXp) end
        return t
    end
    if xpHora <= 0 then
        for _, l in ipairs({ui.potXpBase, ui.potSem, ui.potAgora}) do l:setText("--") end
        for _, l in ipairs(HA.linhasPotions) do l.valor:setText("--") end
        HA.mostrarAviso("Cace 1 min pra medir a XP")
        return
    end
    local base = xpHora / potMult
    ui.potXpBase:setText(HA.formatar(xpHora))
    ui.potSem:setText(texto(base))
    ui.potAgora:setText(texto(xpHora))
    for _, l in ipairs(HA.linhasPotions) do
        local ganho = base * l.k * HA.POTION_PCT / 100
        l.valor:setText(texto(base + ganho))
        l.valor:setTooltip("Total por hora com " .. l.k .. " potions.\nAs potions somam " .. texto(ganho, "+") .. " ao Sem potion.")
    end
    HA.mostrarAviso("")
end

function HA.atualizarPainel()
    local s = HA.sessao()
    local lucro = s.lootValor + s.ouro
    ui.relogio:setText(HA.formatarTempo(s.seg))
    ui.pausar:setText(s.pausado and "Retomar" or "Pausar")
    ui.relogio:setColor(s.pausado and "#888888" or "#4AA3FF")
    ui.lucro:setText(HA.tokens(lucro))
    ui.lucroHora:setText(HA.tokens(HA.porHora(lucro, s)))
    ui.kills:setText(tostring(s.kills))
    ui.xp:setText(HA.formatar(s.xp))
    ui.xpMin:setText(HA.formatar(HA.porTempo(s.xp, s, 60)))
    ui.xp10:setText(HA.formatar(HA.porTempo(s.xp, s, 600)))
    ui.xpHora:setText(HA.formatar(HA.porHora(s.xp, s)))
    ui.niv:setText(math.floor(s.niveis) .. " lvl")
    ui.nivMin:setText(HA.textoNiveis(HA.porTempo(s.niveis, s, 60)))
    ui.niv10:setText(math.floor(HA.porTempo(s.niveis, s, 600) + 0.5) .. " lvl")
    ui.nivHora:setText(math.floor(HA.porHora(s.niveis, s) + 0.5) .. " lvl")
    local xp15, niv15 = HA.recente(s, "xp"), HA.recente(s, "niveis")
    ui.xp15:setText(xp15 and HA.formatar(xp15) or "--")
    ui.niv15:setText(niv15 and (math.floor(niv15 + 0.5) .. " lvl") or "--")
    ui.proxNivel:setText(HA.proximoNivel(s))
    ui.repassar:setText("Analyser do client: " .. (cfg.repassar and "ON" or "OFF"))
    ui.repassar:setColor(cfg.repassar and "#77FF77" or "#FF8888")
    if not HA.conectado then
        ui.status:setText("Sem dados do servidor (Analyser ausente)")
        ui.status:setColor("#FF7777")
    elseif HA.dadosServidor then
        ui.status:setText("Recebendo dados do servidor")
        ui.status:setColor("#55DD55")
    else
        ui.status:setText("Esperando o primeiro loot/dano...")
        ui.status:setColor("#888888")
    end
    if HA.lootMudou then HA.atualizarItens() end
    for k, d in pairs(HA.widgetsDrop) do
        local qtd = s.loot[k] or 0
        pcall(function() d.w:setTooltip(HA.textoDrop(s, k, d.nome, qtd, qtd * HA.preco(tonumber(k)))) end)
    end
    if HA.bichosMudou then HA.atualizarBichos() end
    HA.pintarTeste()
    if HA.testesMudou then HA.atualizarTestes() end
    if cfg.aba == "potions" then HA.atualizarPotions() end
end

ui.pausar.onClick = function()
    local s = HA.sessao()
    s.pausado = not s.pausado
    HA.atualizarPainel()
end
ui.zerar.onClick = function()
    HA.zerarSessao()
    HA.atualizarPainel()
end
ui.repassar.onClick = function()
    cfg.repassar = not cfg.repassar
    HA.atualizarPainel()
end
el("closeButton").onClick = function() w:hide() end
if cfg.aba ~= "testes" and cfg.aba ~= "potions" then cfg.aba = "hunt" end
function HA.mostrarAba(aba)
    cfg.aba = aba
    ui.paginaHunt:setVisible(aba == "hunt")
    ui.paginaTestes:setVisible(aba == "testes")
    ui.paginaPotions:setVisible(aba == "potions")
    ui.abaHunt:setColor(aba == "hunt" and "#FFD24A" or "#888888")
    ui.abaTestes:setColor(aba == "testes" and "#FFD24A" or "#888888")
    ui.abaPotions:setColor(aba == "potions" and "#FFD24A" or "#888888")
    if aba == "potions" then HA.atualizarPotions() end
    HA.ajustarAltura()
end
cfg.minimizado = cfg.minimizado or {}
HA.SECOES = {
    {id = "sSessao", itens = {"linhaRelogio", "lLucro", "lLucroHora", "lKills"}},
    {id = "sBichos", itens = {"lAtual", "listaBichos"}},
    {id = "sSaques", itens = {"itens"}},
    {id = "sExp", itens = {"lXp", "lXpMin", "lXp10", "lXpHora", "lXp15", "lNiv", "lNivMin", "lNiv10", "lNivHora", "lNiv15", "lProxNivel"}},
}
function HA.aplicarSecao(sec)
    local fechada = cfg.minimizado[sec.id] == true
    for _, id in ipairs(sec.itens) do el(id):setVisible(not fechada) end
    el(sec.id):getChildById("min"):setText(fechada and "+" or "-")
end
for _, sec in ipairs(HA.SECOES) do
    el(sec.id):getChildById("min").onClick = function()
        cfg.minimizado[sec.id] = not cfg.minimizado[sec.id]
        HA.aplicarSecao(sec)
        HA.ajustarAltura()
    end
    HA.aplicarSecao(sec)
end
ui.abaHunt.onClick = function() HA.mostrarAba("hunt") end
ui.abaTestes.onClick = function() HA.mostrarAba("testes") end
ui.abaPotions.onClick = function() HA.mostrarAba("potions") end
function HA.atualizarCampoPotions()
    HA.mudandoCampo = true
    ui.pQtd:setText(tostring(HA.bonusChar().potions or 0))
    HA.mudandoCampo = false
    HA.atualizarPainel()
end
ui.pQtd:setText(tostring(HA.bonusChar().potions or 0))
ui.pQtd:setTooltip("Potions de XP ativas (0 a " .. HA.MAX_POTIONS .. ").\nPreenche sozinho ao usar o combo e zera apos 30 min.")
ui.pQtd.onTextChange = function(widget, texto)
    if HA.mudandoCampo then return end
    local n = tonumber(texto)
    if n and n >= 0 and n <= HA.MAX_POTIONS then
        local b = HA.bonusChar()
        b.potions = math.floor(n)
        b.usadasEm = nil
        HA.atualizarPainel()
    end
end
ui.pLerBonus.onClick = function()
    say("!bonusxp")
end
ui.totalBonus:setTooltip("(1 + Activity) x (1 + potions x 5%).\nSupoe que o Activity multiplica a XP.\nStamina e Double XP ficam de fora.")
ui.potXpBase:setTooltip("XP por hora dos ultimos 15 min (ou da sessao), com as potions ativas.")
HA.MAX_MINUTOS = 600
ui.tMinutos:setText(tostring(math.floor(cfg.duracaoTeste / 60)))
ui.tNome:setText(cfg.nomeTeste)
ui.tMinutos.onTextChange = function(widget, texto)
    local n = tonumber(texto)
    if n and n >= 1 and n <= HA.MAX_MINUTOS then
        cfg.duracaoTeste = math.floor(n) * 60
        HA.atualizarPainel()
    end
end
ui.tNome.onTextChange = function(widget, texto) cfg.nomeTeste = texto end
ui.tMinutos:setTooltip("Minutos do teste (1 a " .. HA.MAX_MINUTOS .. ").")
for _, d in ipairs({{"t10", 600}, {"t20", 1200}, {"t30", 1800}}) do
    ui[d[1]].onClick = function()
        ui.tMinutos:setText(tostring(d[2] / 60))
    end
end
ui.tIniciar.onClick = function()
    local s = HA.sessao()
    if s.teste then HA.terminarTeste(s) else HA.iniciarTeste() end
    HA.atualizarPainel()
end
ui.tApagar.onClick = function()
    local lista = HA.testes()
    table.sort(HA.selecionados, function(a, b) return a > b end)
    for _, i in ipairs(HA.selecionados) do
        if lista[i] then table.remove(lista, i) end
    end
    HA.selecionados = {}
    HA.testesMudou = true
    HA.atualizarPainel()
end
ui.tNome:setTooltip("Nome da hunt (opcional). Vazio = nome do bicho que mais matou no teste.")

HA.ultimoTick = os.time()
HA.ultimaXp, HA.ultimoNivel = nil, nil
macro(1000, function()
    local agora = os.time()
    local passou = agora - (HA.ultimoTick or agora)
    HA.ultimoTick = agora
    if not g_game.isOnline() then
        HA.ultimaXp, HA.ultimoNivel = nil, nil
        return
    end
    local s = HA.sessao()
    local okX, xp = pcall(function() return player:getExperience() end)
    if okX and xp then
        if HA.ultimaXp and xp > HA.ultimaXp and not s.pausado then s.xp = s.xp + (xp - HA.ultimaXp) end
        HA.ultimaXp = xp
    end
    local nv = HA.nivelAtual()
    if nv then
        if HA.ultimoNivel and nv > HA.ultimoNivel and not s.pausado then s.niveis = s.niveis + (nv - HA.ultimoNivel) end
        HA.ultimoNivel = nv
    end
    if not s.pausado and passou > 0 and passou < 10 then s.seg = s.seg + passou end
    HA.amostrar(s)
    HA.checarTeste(s)
    HA.checarFimPotions()
    if w:isVisible() then HA.atualizarPainel() end
end)

function HA.alternarPainel()
    if w:isVisible() then
        w:hide()
    else
        w:show()
        w:raise()
        HA.lootMudou = true
        HA.bichosMudou = true
        HA.testesMudou = true
        HA.atualizarPainel()
    end
end
addButton("HuntAnalyzerBtn", "Hunt Analyzer", HA.alternarPainel)

HA.lootMudou = true
HA.bichosMudou = true
HA.testesMudou = true
HA.atualizarPainel()
HA.mostrarAba(cfg.aba)
