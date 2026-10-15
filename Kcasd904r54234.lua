setDefaultTab("Main")
HuntAnalyzer = HuntAnalyzer or {}
HuntAnalyzer.VERSAO = "3.3"

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
HA.MONSTROS = {
    {"Demolisher Maior Domus", 4760003, 40077800, 27766570, 1510, "500-700"},
    {"Demolisher Moonspawn Oozecrown", 4760003, 40077800, 15061531, 1522, "500-700"},
    {"Demolisher Elyraxs Spirit", 3760003, 35077800, 23964004, 1461, "400-500"},
    {"Demolisher Night Harpy", 3760003, 35077800, 12798395, 1470, "400-500"},
    {"Demolisher Gloom Maw", 2904003, 27077800, 16141548, 1451, "400-500"},
    {"Demolisher Varg", 2904003, 27077800, 8608025, 1442, "400-500"},
    {"Demolisher Bone Bear", 2640003, 26077800, 13554805, 1466, "400-500"},
    {"Eldritch Dragon Lord", 2640003, 26077800, 7828125, 1457, "400-500"},
    {"Demolisher Crypt Construct", 2376003, 24077800, 6335996, 1465, "400-500"},
    {"Demolisher Crypt Fiend", 2376003, 24077800, 12313506, 1463, "400-500"},
    {"Demolisher Hawk Hopper", 2244003, 22077800, 6776219, 1445, "400-500"},
    {"Demolisher Lion Hydra", 2244003, 22077800, 12100997, 1446, "400-500"},
    {"Demolisher Arcdrill Centurion", 1848003, 20077800, 6303390, 1230, "210-250"},
    {"Demolisher Molten Gearmancer", 1848003, 20077800, 12040404, 1229, "210-250"},
    {"Demolisher Candy Swirl Titan", 1584003, 19077800, 6291045, 1220, "210-250"},
    {"Demolisher Candyfloss Horror", 1584003, 19077800, 11350710, 1211, "210-250"},
    {"Demolisher Gnarlwood Devourer", 1452003, 18077800, 10881798, 1233, "210-250"},
    {"Demolisher Witherblossom Maw", 1452003, 18077800, 6166597, 1232, "210-250"},
    {"Demolisher Gorger Inferniarch", 1320003, 18077800, 10417725, 1255, "210-250"},
    {"Demolisher Sineater Inferniarch", 1320003, 18077800, 5884489, 1253, "210-250"},
    {"Demolisher Brinebrute Inferniarch", 1188003, 17077800, 10193749, 1252, "210-250"},
    {"Demolisher Spellreaper Inferniarch", 1188003, 17077800, 5744301, 1250, "210-250"},
    {"Demolisher Darklight Emitter", 924003, 15077800, 5467955, 702, "160-200"},
    {"Demolisher Wandering Pillar", 924003, 15077800, 9734298, 697, "160-200"},
    {"Demolisher Bloodjaw", 726003, 12077800, 9506810, 701, "160-200"},
    {"Demolisher Converter", 726003, 12077800, 5215772, 705, "160-200"},
    {"Demolisher Ichgahal", 620403, 12077800, 5061679, 691, "160-200"},
    {"Demolisher Murcion", 620403, 12077800, 9027634, 692, "160-200"},
    {"Demolisher Oozing Carcass", 554403, 11077800, 8840493, 703, "160-200"},
    {"Demolisher Oozing Corpus", 554403, 11077800, 4949614, 704, "160-200"},
    {"Demolisher Bloated Man Maggot", 488403, 10077800, 4814248, 700, "160-200"},
    {"Demolisher Rotten Man Maggot", 488403, 10077800, 8404544, 699, "160-200"},
    {"Demolisher Frozen Horror", 435603, 10077800, 7760693, 554, "110-150"},
    {"Demolisher Lavafungus", 435603, 10077800, 4612787, 555, "110-150"},
    {"Demolisher Gorzindel", 356403, 8077800, 7135934, 552, "110-150"},
    {"Demolisher Prospector", 356403, 8077800, 4531500, 553, "110-150"},
    {"Demolisher Animated Feather", 330003, 7577800, 3771450, 550, "110-150"},
    {"Demolisher Ghulosh", 330003, 7577800, 6718717, 551, "110-150"},
    {"Demolisher Dark Carnisylvan", 264003, 7077800, 3526309, 548, "110-150"},
    {"Demolisher Great Schnitzel", 264003, 7077800, 5986897, 549, "110-150"},
    {"Demolisher Branchy Demon", 224403, 6577800, 5929038, 547, "110-150"},
    {"Demolisher Cloak Of Terror", 224403, 6577800, 3406002, 546, "110-150"},
    {"Demolisher Titan Shadow", 120002, 5077800, 2689731, 522, "custom"},
    {"Demolisher Titan Thanatursus", 120002, 5077800, 2808742, 533, "custom"},
    {"Demolisher Titan Doomhauler", 90002, 4077800, 2417200, 540, "custom"},
    {"Demolisher Titan Serpent", 90002, 4077800, 1986694, 536, "custom"},
    {"Demolisher Titan Astral Power", 80002, 3777800, 1618796, 539, "custom"},
    {"Demolisher Titan Shadowpelt", 80002, 3777800, 2276088, 541, "custom"},
    {"Demolisher Leaf Golem", 70002, 3477800, 2141845, 516, "custom"},
    {"Demolisher Librarian", 70002, 3477800, 1287770, 529, "custom"},
    {"Demolisher Hungry Baron", 65002, 3277800, 2006915, 526, "custom"},
    {"Demolisher Outcast", 65002, 3277800, 1168364, 534, "custom"},
    {"Demolisher Count Of The Core", 60002, 3077800, 1883423, 527, "custom"},
    {"Demolisher Glooth Anemone", 60002, 3077800, 1086001, 535, "custom"},
    {"Demolisher Branchy Crawler", 55002, 3077800, 1635337, 513, "custom"},
    {"Demolisher Teneshpar", 55002, 3077800, 992784, 360, "custom"},
    {"Demolisher Breach Brood", 50002, 2777800, 902901, 538, "custom"},
    {"Demolisher Hibernal Moth", 50002, 2777800, 1516605, 542, "custom"},
    {"Demolisher Devouring Fish", 45002, 2577800, 818292, 537, "custom"},
    {"Demolisher Nightmare Tendril", 45002, 2577800, 1405282, 353, "custom"},
    {"Demolisher Misguided Shadow", 40002, 2577800, 817683, 522, "custom"},
    {"Demolisher Thanatursus", 40002, 2577800, 1174185, 533, "custom"},
    {"Demolisher Orclops Doomhauler", 35002, 2277800, 1100497, 540, "custom"},
    {"Demolisher Seacrest Serpent", 35002, 2277800, 738420, 536, "custom"},
    {"Demolisher Astral Power", 30002, 2077800, 659015, 539, "custom"},
    {"Demolisher Shadowpelt", 30002, 2077800, 1006424, 541, "custom"},
    {"Abominable Giant Werewolf", 27004, 1777800, 537000, 504, "custom"},
    {"Demolisher King Zelos", 25018, 2077800, 359131, 503, "custom"},
    {"Demolisher Ogre Ruffian", 22877, 1277800, 206446, 398, "custom"},
    {"Demolisher Chopper", 20919, 1577800, 93068, 373, "custom"},
    {"Demolisher Hive Overseer", 19130, 1277800, 172422, 371, "custom"},
    {"Demolisher Rotspit", 17494, 1277800, 116231, 372, "custom"},
    {"Demolisher Deep Vision", 15998, 977800, 137267, 369, "custom"},
    {"Demolisher Toothy Fish", 14629, 977800, 82620, 368, "custom"},
    {"Demolisher Titanus", 11185, 807800, 82620, 79, "custom"},
    {"Demolisher Saphira", 10228, 707800, 39290, 351, "custom"},
    {"Demolisher Demon Supremo", 10042, 506000, 32545, 12, "custom"},
    {"Demolisher Criost", 9352, 577800, 51945, 248, "custom"},
    {"Demolisher Blaze Hydra", 8552, 500800, 57050, 493, "custom"},
    {"Demolisher Hydra Suprema", 7152, 477800, 57050, 106, "custom"},
    {"Demolisher Guzzlemaw", 6540, 347800, 36080, 98, "custom"},
    {"Frost Viserion Dragon", 5469, 400200, 27335, 248, "custom"},
    {"Taco", 5001, 307800, 18984, 128, "custom"},
    {"Super Demolisher Hellhound", 3824, 150000, 40000, 240, "custom"},
    {"Demolisher Addiction Dragon", 3497, 247800, 32080, 351, "custom"},
    {"Super Demolisher Rotworm", 3198, 280200, 40000, 295, "custom"},
    {"Demolisher Hydra", 2674, 156200, 13135, 121, "custom"},
    {"Demolisher Draconia", 2446, 145700, 11220, 34, "custom"},
    {"Dexter", 2236, 288200, 16720, 128, "Dexter"},
    {"Super Demolisher Dragon", 2045, 125700, 12050, 39, "custom"},
    {"Demolisher Dragon", 1870, 105700, 2050, 39, "custom"},
    {"Chandler Bing", 1094, 150200, 11220, 128, "Friends"},
    {"Demolisher Grim Reaper", 1000, 95200, 5050, 300, "Undead Humanoids"},
}
HA.monstroPorChave = {}
for _, m in ipairs(HA.MONSTROS) do
    HA.monstroPorChave[m[1]:lower():gsub("^demolisher ", "")] = m
end
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
    HA.aoKillHunt(HA.monstroDoNome(nome), xp)
end

HA.KILLS_JANELA = 20
HA.PARADO_S = 60
HA.MIN_MEDIDO_S = 120
HA.ultimosKills = {}

function HA.huntsChar()
    local k = nomeChar()
    cfg.hunts = cfg.hunts or {}
    cfg.hunts[k] = cfg.hunts[k] or {}
    return cfg.hunts[k]
end

function HA.huntAtual()
    local cont, melhor, maior = {}, nil, 0
    for _, nome in ipairs(HA.ultimosKills) do
        cont[nome] = (cont[nome] or 0) + 1
        if cont[nome] > maior then melhor, maior = nome, cont[nome] end
    end
    return melhor
end

function HA.registroHunt(nome)
    local h = HA.huntsChar()
    h[nome] = h[nome] or {seg = 0, kills = 0, xp = 0, niveis = 0, xpBase = 0, xpConhecido = 0}
    return h[nome]
end

function HA.aoKillHunt(m, xp)
    if not m then return end
    table.insert(HA.ultimosKills, m[1])
    while #HA.ultimosKills > HA.KILLS_JANELA do table.remove(HA.ultimosKills, 1) end
    HA.ultimoKillEm = os.time()
    local r = HA.registroHunt(HA.huntAtual())
    r.kills = r.kills + 1
    r.xpBase = r.xpBase + m[2]
    r.xpConhecido = r.xpConhecido + xp
end

function HA.somarTempoHunt(passou, ganhoXp, ganhoNiv)
    if not HA.ultimoKillEm or os.time() - HA.ultimoKillEm > HA.PARADO_S then return end
    local nome = HA.huntAtual()
    if not nome then return end
    local r = HA.registroHunt(nome)
    r.seg = r.seg + passou
    r.xp = r.xp + ganhoXp
    r.niveis = r.niveis + ganhoNiv
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

function HA.potionsDoClient()
    local ok, lista = pcall(function() return modules.game_exppotions.getBotSnapshot() end)
    if not ok or type(lista) ~= "table" or #lista == 0 then return nil end
    local n, menor = 0, nil
    for _, p in ipairs(lista) do
        local seg = tonumber(p.seconds) or 0
        if seg > 0 then
            n = n + 1
            menor = menor and math.min(menor, seg) or seg
        end
    end
    return math.min(n, HA.MAX_POTIONS), menor
end

function HA.checarFimPotions()
    local b = HA.bonusChar()
    local n, menor = HA.potionsDoClient()
    HA.fonteClient = n ~= nil
    HA.menorRestante = menor
    if n then
        local mudou = b.potions ~= n
        b.potions = n
        b.usadasEm = nil
        if mudou and HA.atualizarCampoPotions then HA.atualizarCampoPotions() end
        return
    end
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

HAMonstro < UIButton
  height: 34
  background-color: #1A1A1AEE
  border-width: 1
  border-color: #333333
  $hover:
    border-color: #8A8A8A
  UICreature
    id: icone
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    size: 32 32
    phantom: true
  UILabel
    id: nome
    anchors.left: icone.right
    anchors.right: parent.right
    anchors.top: parent.top
    margin-left: 3
    margin-top: 3
    height: 14
    font: verdana-11px-rounded
    color: #FFFFFF
    phantom: true
  UILabel
    id: info
    anchors.left: icone.right
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    margin-left: 3
    margin-bottom: 3
    height: 14
    font: verdana-11px-rounded
    color: #6BB6FF
    phantom: true

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
        width: 38
      HABtn
        id: abaTestes
        text: TESTES
        width: 46
      HABtn
        id: abaPotions
        text: POTIONS
        width: 52
      HABtn
        id: abaBichos
        text: BICHOS
        width: 42
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
    Panel
      id: paginaBichos
      visible: false
      layout:
        type: verticalBox
        spacing: 1
        fit-children: true
      TextEdit
        id: mBusca
        height: 18
        margin-top: 2
        font: verdana-11px-rounded
      Panel
        id: mCaixa
        height: 160
        margin-top: 2
        ScrollablePanel
          id: mLista
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.bottom: parent.bottom
          anchors.right: mScroll.left
          vertical-scrollbar: mScroll
          Panel
            id: mItens
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            layout:
              type: verticalBox
              spacing: 1
              fit-children: true
        VerticalScrollBar
          id: mScroll
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          anchors.right: parent.right
          step: 35
          pixels-scroll: true
      HASecao
        id: mTitulo
        text: Escolha um bicho
      HALinha
        id: lMBase
      HALinha
        id: lMVida
      HALinha
        id: lMKill
      HALinha
        id: lMKills
      HALinha
        id: lMXpHora
      HALinha
        id: lMLvlHora
      HALinha
        id: lMComp
      UILabel
        id: mAviso
        height: 28
        font: verdana-11px-rounded
        color: #888888
        text-wrap: true
      HABtn
        id: mApagar
        text: Apagar medicao deste bicho
        visible: false
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

ui.paginaBichos, ui.abaBichos, ui.mBusca, ui.mItens = el("paginaBichos"), el("abaBichos"), el("mBusca"), el("mItens")
ui.mTitulo, ui.mAviso, ui.mApagar = el("mTitulo"), el("mAviso"), el("mApagar")
ui.mApagar.onClick = function()
    if cfg.bichoEscolhido then HA.huntsChar()[cfg.bichoEscolhido] = nil end
    HA.atualizarBichosEscolha()
    HA.ajustarAltura()
end
ui.mBase = linha("lMBase", "XP base")
ui.mVida = linha("lMVida", "Vida / hit max")
ui.mKill = linha("lMKill", "XP por kill (voce)", "#77FF77")
ui.mKills = linha("lMKills", "Kills por hora", "#CCCCCC")
ui.mXpHora = linha("lMXpHora", "XP por hora", "#77FF77")
ui.mLvlHora = linha("lMLvlHora", "Lvl por hora", "#FFD24A")
ui.mComp = linha("lMComp", "vs hunt atual", "#6BB6FF")

function HA.cortar(txt, max)
    if #txt <= max then return txt end
    return txt:sub(1, max - 1) .. "."
end

HA.linhasMonstros = {}
for _, m in ipairs(HA.MONSTROS) do
    local b = g_ui.createWidget("HAMonstro", ui.mItens)
    pcall(function() b:getChildById("icone"):setOutfit({type = m[5]}) end)
    b:getChildById("nome"):setText(HA.cortar((m[1]:gsub("^Demolisher ", "")), 22))
    b:getChildById("info"):setText(HA.formatar(m[2]) .. " xp  " .. (m[6]:find("%d") and ("TP " .. m[6]) or m[6]))
    b:setTooltip(m[1])
    b.onClick = function()
        cfg.bichoEscolhido = m[1]
        HA.atualizarBichosEscolha()
        HA.ajustarAltura()
    end
    table.insert(HA.linhasMonstros, {w = b, m = m, busca = m[1]:lower()})
end

function HA.filtrarMonstros(texto)
    local t = tostring(texto or ""):lower()
    for _, l in ipairs(HA.linhasMonstros) do
        l.w:setVisible(t == "" or l.busca:find(t, 1, true) ~= nil)
    end
end

function HA.monstroDoNome(nome)
    return HA.monstroPorChave[tostring(nome or ""):lower():gsub("^demolisher ", "")]
end

function HA.calibrar(s)
    local xpReal, xpBase, vidaTotal = 0, 0, 0
    for nome, b in pairs(s.bichos) do
        local m = HA.monstroDoNome(nome)
        if m then
            xpReal = xpReal + b.xp
            xpBase = xpBase + b.n * m[2]
            vidaTotal = vidaTotal + b.n * m[3]
        end
    end
    if xpBase <= 0 or s.seg < 60 then return nil end
    return {mult = xpReal / xpBase, danoHora = vidaTotal * 3600 / s.seg}
end

function HA.lvlPorXp(s)
    if s.xp > 0 and s.niveis > 0 then return s.niveis / s.xp end
    local ok, falta = pcall(function()
        local lv = player:getLevel()
        return modules.game_skills.expForLevel(lv + 1) - modules.game_skills.expForLevel(lv)
    end)
    if ok and tonumber(falta) and falta > 0 then return 1 / falta end
    return nil
end

function HA.atualizarBichosEscolha()
    local m
    for _, l in ipairs(HA.linhasMonstros) do
        local escolhido = l.m[1] == cfg.bichoEscolhido
        if escolhido then m = l.m end
        l.w:setBorderColor(escolhido and "#FFD24A" or "#333333")
    end
    local linhas = {ui.mBase, ui.mVida, ui.mKill, ui.mKills, ui.mXpHora, ui.mLvlHora, ui.mComp}
    for _, l in ipairs(linhas) do l:setText("--") end
    local hunts = HA.huntsChar()
    for _, l in ipairs(HA.linhasMonstros) do
        local r = hunts[l.m[1]]
        l.w:getChildById("nome"):setColor((r and r.seg >= HA.MIN_MEDIDO_S) and "#77FF77" or "#FFFFFF")
    end
    if not m then
        ui.mTitulo:setText("Escolha um bicho")
        ui.mAviso:setText("Clique num bicho. Verde = hunt ja medida")
        ui.mApagar:setVisible(false)
        return
    end
    ui.mTitulo:setText(HA.cortar((m[1]:gsub("^Demolisher ", "")), 26))
    ui.mBase:setText(HA.formatar(m[2]))
    ui.mVida:setText(HA.formatar(m[3]) .. " / " .. HA.formatar(m[4]))
    local s = HA.sessao()
    local c = HA.calibrar(s)
    local r = hunts[m[1]]
    ui.mApagar:setVisible(r ~= nil)
    local xpKill, killsHora, xpHora, lpx, aviso
    if r and r.seg >= HA.MIN_MEDIDO_S and r.kills > 0 then
        local bonusEpoca = r.xpBase > 0 and r.xpConhecido / r.xpBase or nil
        local ajuste = (c and bonusEpoca and bonusEpoca > 0) and c.mult / bonusEpoca or 1
        xpKill = r.xpConhecido / r.kills * ajuste
        killsHora = r.kills * 3600 / r.seg
        xpHora = r.xp * 3600 / r.seg * ajuste
        lpx = HA.lvlPorXp(s) or ((r.xp > 0 and r.niveis > 0) and r.niveis / r.xp or nil)
        aviso = "MEDIDO em " .. HA.tempoCurto(r.seg) .. " (" .. r.kills .. " kills)" ..
            (ajuste ~= 1 and string.format(". Ajustado ao bonus de agora x%.2f", c.mult) or "")
    elseif c then
        xpKill = m[2] * c.mult
        killsHora = c.danoHora / m[3]
        xpHora = xpKill * killsHora
        lpx = HA.lvlPorXp(s)
        aviso = string.format("ESTIMADO: bonus x%.2f e o mesmo dano/hora de agora", c.mult)
    else
        ui.mAviso:setText("Mate 1 min de bichos da lista pra medir seu bonus e dano")
        return
    end
    ui.mKill:setText(HA.formatar(xpKill))
    ui.mKills:setText(string.format("%.0f", killsHora))
    ui.mXpHora:setText(HA.formatar(xpHora))
    ui.mLvlHora:setText(lpx and HA.textoLvl(xpHora * lpx) or "--")
    local atual = HA.porHora(s.xp, s)
    if atual > 0 then
        local p = (xpHora / atual - 1) * 100
        ui.mComp:setText((p >= 0 and "+" or "") .. string.format("%.0f%%", p))
        ui.mComp:setColor(p >= 0 and "#77FF77" or "#FF7777")
    end
    ui.mAviso:setText(aviso)
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
    pcall(function() ui.paginaBichos:getLayout():update() end)
    pcall(function() ui.corpo:getLayout():update() end)
    w:setHeight(ui.corpo:getHeight() + 30)
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
    local restante = HA.fonteClient and HA.menorRestante or (b.usadasEm and HA.DURACAO_POTION - (os.time() - b.usadasEm))
    local fim = restante and (" (" .. HA.tempoCurto(restante) .. ")") or ""
    ui.potBonus:setText("+" .. n * HA.POTION_PCT .. "%" .. fim)
    ui.potBonus:getParent():getChildById("nome"):setText(HA.fonteClient and "Pot. client" or "Potions")
    ui.potBonus:setTooltip(HA.fonteClient and "Lido do client: potions com tempo restante. O tempo e o da que acaba primeiro." or "Sem leitura do client: numero do combo ou digitado.")
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
    if cfg.aba == "bichos" then
        HA.tickBichos = (HA.tickBichos or 0) + 1
        if HA.tickBichos % 5 == 0 then HA.atualizarBichosEscolha() end
    end
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
if cfg.aba ~= "testes" and cfg.aba ~= "potions" and cfg.aba ~= "bichos" then cfg.aba = "hunt" end
function HA.mostrarAba(aba)
    cfg.aba = aba
    ui.paginaHunt:setVisible(aba == "hunt")
    ui.paginaTestes:setVisible(aba == "testes")
    ui.paginaPotions:setVisible(aba == "potions")
    ui.paginaBichos:setVisible(aba == "bichos")
    ui.abaHunt:setColor(aba == "hunt" and "#FFD24A" or "#888888")
    ui.abaTestes:setColor(aba == "testes" and "#FFD24A" or "#888888")
    ui.abaPotions:setColor(aba == "potions" and "#FFD24A" or "#888888")
    ui.abaBichos:setColor(aba == "bichos" and "#FFD24A" or "#888888")
    if aba == "potions" then HA.atualizarPotions() end
    if aba == "bichos" then HA.atualizarBichosEscolha() end
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
ui.abaBichos.onClick = function() HA.mostrarAba("bichos") end
ui.mBusca:setTooltip("Buscar bicho pelo nome")
ui.mBusca.onTextChange = function(widget, texto) HA.filtrarMonstros(texto) end
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
    local ganhoXp, ganhoNiv = 0, 0
    if okX and xp then
        if HA.ultimaXp and xp > HA.ultimaXp and not s.pausado then ganhoXp = xp - HA.ultimaXp end
        s.xp = s.xp + ganhoXp
        HA.ultimaXp = xp
    end
    local nv = HA.nivelAtual()
    if nv then
        if HA.ultimoNivel and nv > HA.ultimoNivel and not s.pausado then ganhoNiv = nv - HA.ultimoNivel end
        s.niveis = s.niveis + ganhoNiv
        HA.ultimoNivel = nv
    end
    if not s.pausado and passou > 0 and passou < 10 then
        s.seg = s.seg + passou
        HA.somarTempoHunt(passou, ganhoXp, ganhoNiv)
    end
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
