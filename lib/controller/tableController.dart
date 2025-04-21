import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TableController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable list to store table numbers
  final RxList<String> tableNumbers = <String>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTableNumbers();
  }

  // Fetch table numbers from Firestore
  Future<void> fetchTableNumbers() async {
    isLoading.value = true;
    try {
      final DocumentSnapshot snapshot = await _firestore.collection('tables').doc('tables').get();

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('tables')) {
          final tables = List<String>.from(data['tables']);
          tableNumbers.value = tables;
        } else {
          tableNumbers.value = [];
        }
      } else {
        // If document doesn't exist, initialize with default values
        tableNumbers.value = ['1', '2', '3', '4'];
        await saveTableNumbers();
      }
    } catch (e) {
      print('Error fetching table numbers: $e');
      tableNumbers.value = ['1', '2', '3', '4'];
      Get.snackbar('Failed!' , 'Table number failed to fetch');
    } finally {
      isLoading.value = false;
    }
  }

  // Save table numbers to Firestore
  Future<void> saveTableNumbers() async {
    try {
      await _firestore.collection('tables').doc('tables').set({
        'tables': tableNumbers.toList(),
      });
    } catch (e) {
      print('Error saving table numbers: $e');
      Get.snackbar('Error', 'Failed to save table numbers');
    }
  }

  // Add a new table
  Future<void> addTable(String tableNumber) async {
    if (tableNumber.isEmpty) {
      Get.snackbar('Error', 'Table number cannot be empty');
      return;
    }

    // Check if table already exists
    if (tableNumbers.contains(tableNumber)) {
      Get.snackbar('Error', 'Table number $tableNumber already exists');
      return;
    }

    tableNumbers.add(tableNumber);
    await saveTableNumbers();
    Get.snackbar('Success', 'Table number $tableNumber added');
  }

  // Edit a table
  Future<void> editTable(int index, String newTableNumber) async {
    if (newTableNumber.isEmpty) {
      Get.snackbar('Error', 'Table number cannot be empty');
      return;
    }

    // Check if new table number already exists (except for the one being edited)
    if (tableNumbers.contains(newTableNumber) && tableNumbers[index] != newTableNumber) {
      Get.snackbar('Error', 'Table number $newTableNumber already exists');
      return;
    }

    final oldNumber = tableNumbers[index];
    tableNumbers[index] = newTableNumber;
    await saveTableNumbers();
    Get.snackbar('Success', 'Table number changed from $oldNumber to $newTableNumber');
  }

  // Delete a table
  Future<void> deleteTable(int index) async {
    final deletedNumber = tableNumbers[index];
    tableNumbers.removeAt(index);
    await saveTableNumbers();
    Get.snackbar('Success', 'Table number $deletedNumber deleted');
  }
}