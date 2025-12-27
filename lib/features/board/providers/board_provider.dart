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

// DEĞİŞİKLİK: StateNotifier yerine Notifier kullanıyoruz.
class BoardNotifier extends Notifier<BoardState> {
  final _uuid = const Uuid();

  // DEĞİŞİKLİK: Constructor yerine build() metodu ile başlangıç state'i verilir.
  @override
  BoardState build() {
    return const BoardState();
  }

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

  void updateItemNote(String id, String newNote) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == id) item.copyWith(note: newNote) else item,
      ],
    );
  }

  void bringToFront(String id) {
    final index = state.items.indexWhere((i) => i.id == id);
    if (index == -1 || index == state.items.length - 1) return;

    final item = state.items[index];
    final newItems = List<WishItem>.from(state.items)
      ..removeAt(index)
      ..add(item);

    state = state.copyWith(items: newItems);
  }

  void sendToBack(String id) {
    final index = state.items.indexWhere((i) => i.id == id);
    if (index == -1 || index == 0) return;

    final item = state.items[index];
    final newItems = List<WishItem>.from(state.items)
      ..removeAt(index)
      ..insert(0, item);

    state = state.copyWith(items: newItems);
  }

  void removeItem(String id) {
    state = state.copyWith(
      items: state.items.where((i) => i.id != id).toList(),
      selectedItemId: null,
    );
  }
}

// DEĞİŞİKLİK: StateNotifierProvider yerine NotifierProvider kullanıyoruz.
final boardProvider = NotifierProvider<BoardNotifier, BoardState>(
  BoardNotifier.new,
);
