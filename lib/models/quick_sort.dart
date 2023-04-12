extension QuickSortExtension<T extends num> on List<T> {
  void quickSort({final int low = 0, int? high}) {
    high = high ?? length - 1;
    if (low < high) {
      final int pivotIndex = partition(low, high);
      quickSort(low: low, high: pivotIndex - 1);
      quickSort(low: pivotIndex + 1, high: high);
    }
  }

  int partition(final int low, final int high) {
    final T pivot = this[high];
    int i = low - 1;

    for (int j = low; j < high; j++) {
      if (this[j].compareTo(pivot) < 0) {
        i++;
        swap(i, j);
      }
    }

    swap(i + 1, high);
    return i + 1;
  }

  void swap(final int i, final int j) {
    final T temp = this[i];
    this[i] = this[j];
    this[j] = temp;
  }
}
