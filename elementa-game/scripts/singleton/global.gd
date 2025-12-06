extends Node

var _coins: int = 0

# --- SINAIS ---
signal element_changed(new_atomic_number) 
# 🚨 ESTA LINHA É ESSENCIAL:
signal max_health_changed(new_max_health)

signal power_changed(new_power)

var coins: int: 
	get: 
		return _coins
	set(value):
		if _coins != value:
			_coins = value
			element_changed.emit(_coins)

var destination_level : String = ""

const ELEMENTOS: Dictionary = {
	0: " ", # Mantido, mas ajustado para melhor clareza no HUD inicial
	# Período 1
	1: "Hidrogênio (H) - 1",
	2: "Hélio (He) - 2",
	
	# Período 2
	3: "Lítio (Li) - 3",
	4: "Berílio (Be) - 4",
	5: "Boro (B) - 5",
	6: "Carbono (C) - 6",
	7: "Nitrogênio (N) - 7",
	8: "Oxigênio (O) - 8",
	9: "Flúor (F) - 9",
	10: "Neônio (Ne) - 10",
	
	# Período 3
	11: "Sódio (Na) - 11",
	12: "Magnésio (Mg) - 12",
	13: "Alumínio (Al) - 13",
	14: "Silício (Si) - 14",
	15: "Fósforo (P) - 15",
	16: "Enxofre (S) - 16",
	17: "Cloro (Cl) - 17",
	18: "Argônio (Ar) - 18",
	
	# Período 4
	19: "Potássio (K) - 19",
	20: "Cálcio (Ca) - 20",
	21: "Escândio (Sc) - 21",
	22: "Titânio (Ti) - 22",
	23: "Vanádio (V) - 23",
	24: "Cromo (Cr) - 24",
	25: "Manganês (Mn) - 25",
	26: "Ferro (Fe) - 26",
	27: "Cobalto (Co) - 27",
	28: "Níquel (Ni) - 28",
	29: "Cobre (Cu) - 29",
	30: "Zinco (Zn) - 30",
	31: "Gálio (Ga) - 31",
	32: "Germânio (Ge) - 32",
	33: "Arsênio (As) - 33",
	34: "Selênio (Se) - 34",
	35: "Bromo (Br) - 35",
	36: "Criptônio (Kr) - 36",
	
	# Período 5
	37: "Rubídio (Rb) - 37",
	38: "Estrôncio (Sr) - 38",
	39: "Ítrio (Y) - 39",
	40: "Zircônio (Zr) - 40",
	41: "Nióbio (Nb) - 41",
	42: "Molibdênio (Mo) - 42",
	43: "Tecnécio (Tc) - 43",
	44: "Rutênio (Ru) - 44",
	45: "Ródio (Rh) - 45",
	46: "Paládio (Pd) - 46",
	47: "Prata (Ag) - 47",
	48: "Cádmio (Cd) - 48",
	49: "Índio (In) - 49",
	50: "Estanho (Sn) - 50",
	51: "Antimônio (Sb) - 51",
	52: "Telúrio (Te) - 52",
	53: "Iodo (I) - 53",
	54: "Xenônio (Xe) - 54",
	
	# Período 6 (inclui Lantanídeos)
	55: "Césio (Cs) - 55",
	56: "Bário (Ba) - 56",
	58: "Cério (Ce) - 58",
	59: "Praseodímio (Pr) - 59",
	60: "Neodímio (Nd) - 60",
	61: "Promécio (Pm) - 61",
	62: "Samário (Sm) - 62",
	63: "Európio (Eu) - 63",
	64: "Gadolínio (Gd) - 64",
	65: "Térbio (Tb) - 65",
	66: "Disprósio (Dy) - 66",
	67: "Hólmio (Ho) - 67",
	68: "Érbio (Er) - 68",
	69: "Túlio (Tm) - 69",
	70: "Itérbio (Yb) - 70",
	71: "Lutécio (Lu) - 71",
	
	72: "Háfnio (Hf) - 72",
	73: "Tantálio (Ta) - 73",
	74: "Tungstênio (W) - 74",
	75: "Rênio (Re) - 75",
	76: "Ósmio (Os) - 76",
	77: "Irídio (Ir) - 77",
	78: "Platina (Pt) - 78",
	79: "Ouro (Au) - 79",
	80: "Mercúrio (Hg) - 80",
	81: "Tálio (Tl) - 81",
	82: "Chumbo (Pb) - 82",
	83: "Bismuto (Bi) - 83",
	84: "Polônio (Po) - 84",
	85: "Astato (At) - 85",
	86: "Radônio (Rn) - 86",
	
	# Período 7 (inclui Actinídeos)
	87: "Frâncio (Fr) - 87",
	88: "Rádio (Ra) - 88",
	# Actinídeos (89-103)
	89: "Actínio (Ac) - 89",
	90: "Tório (Th) - 90",
	91: "Protactínio (Pa) - 91",
	92: "Urânio (U) - 92",
	93: "Netúnio (Np) - 93",
	94: "Plutônio (Pu) - 94",
	95: "Amerício (Am) - 95",
	96: "Cúrio (Cm) - 96",
	97: "Berquélio (Bk) - 97",
	98: "Califórnio (Cf) - 98",
	99: "Einstênio (Es) - 99",
	100: "Férmio (Fm) - 100",
	101: "Mendelévio (Md) - 101",
	102: "Nobélio (No) - 102",
	103: "Laurêncio (Lr) - 103",
	
	104: "Rutherfórdio (Rf) - 104",
	105: "Dúbnio (Db) - 105",
	106: "Seabórgio (Sg) - 106",
	107: "Bóhrio (Bh) - 107",
	108: "Hássio (Hs) - 108",
	109: "Meitnério (Mt) - 109",
	110: "Darmstádtio (Ds) - 110",
	111: "Roentgênio (Rg) - 111",
	112: "Copernício (Cn) - 112",
	113: "Nihônio (Nh) - 113",
	114: "Fleróvio (Fl) - 114",
	115: "Moscóvio (Mc) - 115",
	116: "Livermório (Lv) - 116",
	117: "Tennessino (Ts) - 117",
	118: "Oganessônio (Og) - 118"
}



# ... (Código existente de coins e ELEMENTOS) ...

# --- VARIÁVEIS DE VIDA ---
signal health_changed(new_health) # Sinal para notificar o HUD

var max_health: int = 40 # Vida máxima (4 frascos * 10 HP)
var _current_health: int = 40 # Variável privada

# Setter/Getter para a variável de vida atual
var current_health: int:
	get:
		return _current_health
	set(value):
		# Garante que a vida não exceda o máximo nem caia abaixo de zero
		var new_health = clamp(value, 0, max_health) 
		
		if _current_health != new_health:
			_current_health = new_health
	# Emite o sinal sempre que a vida muda
			health_changed.emit(_current_health)


var max_power: int = 20



# NPCS 

var npc_states: Dictionary = {
	"alquimista_first_interact": false, 
	"ferreiro_first_interact": false,
	
	
	"upgrade_tier_1_done": false, 
	"upgrade_tier_2_done": false, 
	"upgrade_tier_3_done": false, 
}
