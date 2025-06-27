extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.has_key = true
		print("Key collected!")

		# Look for Lockbox in the same parent as the key
		var lockbox = get_parent().get_node_or_null("Lockbox")
		if lockbox:
			print("Lockbox found, removing...")
			lockbox.queue_free()
		else:
			print("Lockbox not found!")

		queue_free()  # Remove the key
