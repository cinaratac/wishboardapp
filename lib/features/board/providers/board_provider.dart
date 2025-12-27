import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/wish_item.dart';

@immutable
class BoardState {
  final List<WishItem> items;
  final String? selectedItemId;

  const BoardState({this.items = const [], this.selectedItemId});

  BoardState copyWith({List<WishItem>? items, String? selectedItemId}) {
    return BoardState(
      items: items ?? this.items,
      selectedItemId: selectedItemId,
    );
  }
}

class BoardNotifier extends StateNotifier<BoardState> {
  BoardNotifier() : super(const BoardState());

  final _uuid = const Uuid();

  void addItem(String imagePath) {
    final newItem = WishItem(
      id: _uuid.v4(),
      imagePath: imagePath,
      zIndex: state.items.length,
    );
    state = state.copyWith(
      items: [...state.items, newItem],
      selectedItemId: newItem.id,
    );
  }

  void selectItem(String? id) {
    state = state.copyWith(selectedItemId: id);
  }

  void updateItemPosition(String id, Offset newPosition) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == id) item.copyWith(position: newPosition) else item,
      ],
    );
  }

  void updateItemTransform(String id, double newScale, double newRotation) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == id)
            item.copyWith(scale: newScale, rotation: newRotation)
          else
            item,
      ],
    );
  }

  void bringToFront(String id) {
    if (state.items.isEmpty) return;
    final int maxZ = state.items.fold(
      0,
      (prev, e) => e.zIndex > prev ? e.zIndex : prev,
    );

    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == id) item.copyWith(zIndex: maxZ + 1) else item,
      ],
    );
  }

  void removeItem(String id) {
    state = state.copyWith(
      items: state.items.where((i) => i.id != id).toList(),
      selectedItemId: null,
    );
  }
}

final boardProvider = StateNotifierProvider<BoardNotifier, BoardState>((ref) {
  return BoardNotifier();
});
