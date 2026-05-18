class HabitTemplate {
  final String title;
  final String category;
  final String frequency;
  final String colorHex;
  final String icon;

  const HabitTemplate({
    required this.title,
    required this.category,
    required this.frequency,
    required this.colorHex,
    required this.icon,
  });
}

final List<HabitTemplate> habitTemplates = [
  // Morning Routine
  const HabitTemplate(
    title: 'Drink Water',
    category: 'health',
    frequency: 'daily',
    colorHex: '#4F6EF7',
    icon: 'water',
  ),
  const HabitTemplate(
    title: 'Make Bed',
    category: 'wellness',
    frequency: 'daily',
    colorHex: '#6366F1',
    icon: 'bed',
  ),
  const HabitTemplate(
    title: 'Morning Walk',
    category: 'fitness',
    frequency: 'daily',
    colorHex: '#10B981',
    icon: 'walk',
  ),
  // Deep Work
  const HabitTemplate(
    title: 'Read 10 Pages',
    category: 'study',
    frequency: 'daily',
    colorHex: '#F59E0B',
    icon: 'book',
  ),
  const HabitTemplate(
    title: 'Deep Work Session',
    category: 'work',
    frequency: 'daily',
    colorHex: '#EF4444',
    icon: 'focus',
  ),
  // Health
  const HabitTemplate(
    title: 'Meditation',
    category: 'wellness',
    frequency: 'daily',
    colorHex: '#8B5CF6',
    icon: 'mind',
  ),
  const HabitTemplate(
    title: 'Take Vitamins',
    category: 'health',
    frequency: 'daily',
    colorHex: '#EC4899',
    icon: 'pill',
  ),
];
