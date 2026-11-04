String formatTripDate(DateTime date) {
  const months = [
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
}

DateTime tripEndDate(DateTime start, int days) =>
    DateTime(start.year, start.month, start.day + days - 1);

String tripDateRange(DateTime start, int days) => days <= 1
    ? formatTripDate(start)
    : '${formatTripDate(start)} – ${formatTripDate(tripEndDate(start, days))}';
