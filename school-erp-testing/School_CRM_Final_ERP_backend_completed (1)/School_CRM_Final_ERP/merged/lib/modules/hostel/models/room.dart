import "bed.dart";

class Room {
  final String id;
  final String number;
  final String block;
  final int floor;
  final String type; // Single, Double, Triple, Dormitory
  final int capacity;
  int occupied;
  String status; // Occupied, Vacant, Maintenance, Reserved
  final List<Bed> beds;

  Room({
    required this.id,
    required this.number,
    required this.block,
    required this.floor,
    required this.type,
    required this.capacity,
    required this.occupied,
    required this.status,
    required this.beds,
  });

  int get availableBeds => capacity - occupied;
}
