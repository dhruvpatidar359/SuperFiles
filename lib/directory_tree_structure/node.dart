class Node {
  final int id;
  final String name;
  String summary;
  Node? parent;
  List<Node> children;

  Node({
    required this.id,
    required this.name,
    this.summary = "",
    this.parent,
    List<Node>? children,
  }) : children = children ?? [];

  bool get isLeaf => children.isEmpty;

  void insertChild(int index, Node child) {
    children.insert(index, child);
    child.parent = this;
  }

  void removeChild(Node child) {
    children.remove(child);
    child.parent = null;
  }
}