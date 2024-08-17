extends Node2D

@onready var particles = %CPUParticles2D

func _ready():
    particles.emitting = true