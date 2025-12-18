from flask import Flask, request, jsonify, send_file
import os
import json

app = Flask(__name__)

DATA_FILE = "about_me.json"

# JSON файлдан мәліметті оқу
def load_from_file():
    if os.path.exists(DATA_FILE):
        try:
            with open(DATA_FILE, "r") as file:
                return json.load(file)
        except:
            return {}
    return {}

# JSON файлға жазу
def save_to_file():
    with open(DATA_FILE, "w") as file:
        json.dump(users_data, file, indent=4)

# Server start → load data

users_data = load_from_file()



# GET about_me

@app.route("/about_me/<user_id>", methods=["GET"])
def get_about_me(user_id):
    about_me = users_data.get(user_id, "")
    return jsonify({"aboutMe": about_me})



# POST about_me

@app.route("/about_me/<user_id>", methods=["POST"])
def set_about_me(user_id):
    data = request.json
    about_me_text = data.get("aboutMe", "")

    # Егер text бос болса – өшіреміз
    if about_me_text.strip() == "":
        users_data.pop(user_id, None)
    else:
        users_data[user_id] = about_me_text

    # JSON файлға сақтау
    save_to_file()

    return jsonify({"status": "success", "aboutMe": users_data.get(user_id, "")})


# Папка барын тексеру, болмаса жасау
if not os.path.exists("profile_images"):
    os.makedirs("profile_images")


@app.route('/upload_profile_image/<user_id>', methods=['POST'])
def upload_profile_image(user_id):
    if "image" not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    image = request.files["image"]
    file_path = f"profile_images/{user_id}.png"
    image.save(file_path)

    return jsonify({"message": "Image uploaded successfully"}), 200


@app.route('/profile_image/<user_id>', methods=['GET'])
def get_profile_image(user_id):
    folder = "profile_images"
    for ext in [".png", ".jpg", ".jpeg"]:
        file_path = os.path.join(folder, f"{user_id}{ext}")
        if os.path.exists(file_path):
            return send_file(file_path, mimetype=f"image/{ext[1:]}")

    # Егер қолданушы суреті жоқ болса, default avatar көрсету
    return send_file("static/avatar.png", mimetype="image/png")

@app.route("/delete_profile_image/<user_id>", methods=["DELETE"])
def delete_profile_image(user_id):
    folder = "profile_images"
    for ext in [".jpg", ".png", ".jpeg"]:
        path = os.path.join(folder, f"{user_id}{ext}")
        if os.path.exists(path):
            os.remove(path)
            return jsonify({"success": True}), 200
    return jsonify({"success": False, "error": "File not found"}), 404



if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)

