class_name SaverLoader

extends Node


@onready var player = get_tree().get_first_node_in_group("player")

const filepath: String = "user://savedtime.json"

# var json = null

func save_time():


    if FileAccess.file_exists(filepath):
        print("file exists")
        var file = FileAccess.open(filepath, FileAccess.READ)
        var json = file.get_as_text()
        var saved_data = JSON.parse_string(json)
        saved_data["run_times"].append(player.time)
        var new_json = JSON.stringify(saved_data)
        print(new_json)
        file.close()
        
        write_file(filepath, new_json)

    else:
        print("file does not exist")
        var saved_data = {}
        saved_data["run_times"] = [player.time]
        var json = JSON.stringify(saved_data)
        print(json)
        write_file(filepath, json)

func write_file(filepath, json):
    var file = FileAccess.open(filepath, FileAccess.WRITE)
    file.store_string(json)
    file.close()


# func load_save_file():
#     var file = FileAccess.open(filepath, FileAccess.READ)

#     var json = file.get_as_text()
#     var saved_data = JSON.parse_string(json)

#     return file, saved_data
