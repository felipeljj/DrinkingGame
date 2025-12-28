func _reorder_carousel_cards(nodes_map: Dictionary, center_idx: int, total_count: int):
	var sort_list = []
	for i in nodes_map.keys():
		var node = nodes_map[i]
		if not is_instance_valid(node): continue
		
		var offset = i - center_idx
		if total_count > 4:
			if offset > total_count / 2: offset -= total_count
			elif offset < -total_count / 2: offset += total_count
		
		sort_list.append({"node": node, "dist": abs(offset)})
	
	# Ordenar por distância: maior distância (fundo) primeiro
	# Assim, ao mover para frente sequencialmente, o mais distante fica no fundo
	# e o mais próximo (distância 0) é movido por último, ficando no topo.
	sort_list.sort_custom(func(a, b): return a.dist > b.dist)
	
	for item in sort_list:
		item.node.move_to_front()
