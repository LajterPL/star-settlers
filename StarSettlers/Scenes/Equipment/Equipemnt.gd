extends Resource
class_name Equipment

@export var items : Array[Item] = []## Tablica przedmiotów.

## Maksymalna liczba przedmiotów w tym ekwipunku.
## Liczba slotów w GUI.
@export var max_size : int  = 0


## Funkcja zwracająca przedmiot o podanym indeksie z ekwipunku i usuwająca go z niego
func retrive_item(index : int) -> Item:
	if items.size() < index or index < 0:
		push_error("Invalid index " + str(index) + "for equipment of size " + str(items.size()))
		return null
		
	return items.pop_at(index)
	
## Funkcja dodająca przedmiot do ekwipunku. Zwróci [code]false[/code], jeśli ekwipunek jest pełny.
func transfer_item(item : Item) -> bool:
	if items.size() >= max_size:
		return false
	
	items.append(item)
	items.sort_custom(func(a, b): return a.name > b.name)
	return true

