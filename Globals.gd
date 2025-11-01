extends Node

enum{Q1, Q2, Q3, Q4}

func global_emit(sig):
	sig.emit()

func global_connector(sig, node, fun):
	node.connect(sig, node, fun)
