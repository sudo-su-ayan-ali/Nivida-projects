class HostelBlock {
  final String id;
  final String name;
  final String code;
  final int floors;
  final int rooms;
  final int capacity;
  final int occupied;
  final String status;

  const HostelBlock({
    required this.id,
    required this.name,
    required this.code,
    required this.floors,
    required this.rooms,
    required this.capacity,
    required this.occupied,
    required this.status,
  });

  int get vacant => capacity - occupied;
  double get occupancyRate => capacity == 0 ? 0 : occupied / capacity;
}
