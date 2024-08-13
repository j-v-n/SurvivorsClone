extends TextureRect

var upgrade = null

func _ready():
	if upgrade != null:
		if upgrade in ["disc1", "disc2", "disc3", "disc4"]:
			$ItemTexture.texture = load(UpgradeDb.UPGRADES[upgrade]["icon"])
			$ItemTexture.scale = Vector2(0.16, 0.16)
		else:
			$ItemTexture.texture = load(UpgradeDb.UPGRADES[upgrade]["icon"])
