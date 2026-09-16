class Validators {
  static const int maxPrice = 300000;

  static String? requiredField(String? value, {String label = 'поле'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Заполните $label';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String label = 'Поле'}) {
    if (value == null || value.trim().length < min) {
      return '$label: не меньше $min символов';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String label = 'Поле'}) {
    if (value != null && value.trim().length > max) {
      return '$label: не больше $max символов';
    }
    return null;
  }

  static String? email(String? value) {
    final required = requiredField(value, label: 'почту');
    if (required != null) return required;
    final tooLong = maxLength(value, 120, label: 'Почта');
    if (tooLong != null) return tooLong;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim());
    if (!ok) return 'Некорректный адрес почты';
    return null;
  }

  static String? positiveInt(String? value, {String label = 'Значение'}) {
    final required = requiredField(value, label: label.toLowerCase());
    if (required != null) return required;
    final n = int.tryParse(value!.trim());
    if (n == null) return '$label должно быть целым числом';
    if (n <= 0) return '$label должно быть больше 0';
    return null;
  }

  static String? nonNegativeInt(String? value, {String label = 'Значение'}) {
    final required = requiredField(value, label: label.toLowerCase());
    if (required != null) return required;
    final n = int.tryParse(value!.trim());
    if (n == null) return '$label должно быть целым числом';
    if (n < 0) return '$label не может быть отрицательным';
    return null;
  }

  static String? intRange(
    String? value, {
    required int min,
    required int max,
    String label = 'Значение',
  }) {
    final required = requiredField(value, label: label.toLowerCase());
    if (required != null) return required;
    final n = int.tryParse(value!.trim());
    if (n == null) return '$label должно быть целым числом';
    if (n < min || n > max) return '$label: от $min до $max';
    return null;
  }

  static String? price(String? value) {
    return intRange(value, min: 1, max: maxPrice, label: 'Цена');
  }

  static String suggestTourCode() {
    final now = DateTime.now();
    final n = (now.millisecondsSinceEpoch % 100000).toString().padLeft(5, '0');
    return 'TY-${now.year}-$n';
  }

  static String? tourCode(String? value) {
    final required = requiredField(value, label: 'код тура');
    if (required != null) return required;
    final tooShort = minLength(value, 4, label: 'Код');
    if (tooShort != null) return tooShort;
    final tooLong = maxLength(value, 20, label: 'Код');
    if (tooLong != null) return tooLong;
    final text = value!.trim();
    if (RegExp(r'[А-Яа-яЁё]').hasMatch(text)) {
      return 'Код: английская раскладка (E и K, не Е и К)';
    }
    final ok = RegExp(r'^[A-Za-z0-9\-]+$').hasMatch(text);
    if (!ok) return 'Код: только латиница, цифры и дефис';
    return null;
  }

  static String? title(String? value) {
    final required = requiredField(value, label: 'название');
    if (required != null) return required;
    final tooShort = minLength(value, 2, label: 'Название');
    if (tooShort != null) return tooShort;
    return maxLength(value, 80, label: 'Название');
  }

  static String? personName(String? value, {String label = 'Имя'}) {
    final required = requiredField(value, label: label.toLowerCase());
    if (required != null) return required;
    final tooShort = minLength(value, 2, label: label);
    if (tooShort != null) return tooShort;
    return maxLength(value, 40, label: label);
  }

  static String? phone(String? value) {
    final required = requiredField(value, label: 'телефон');
    if (required != null) return required;
    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 15) {
      return 'Телефон: от 10 до 15 цифр';
    }
    return maxLength(value, 20, label: 'Телефон');
  }

  static bool passwordHasMinLength(String value) => value.length >= 8;

  static bool passwordHasDigit(String value) => RegExp(r'\d').hasMatch(value);

  static bool passwordHasSpecial(String value) =>
      RegExp(r'[^A-Za-z0-9]').hasMatch(value);

  static bool passwordStrong(String value) =>
      passwordHasMinLength(value) &&
      passwordHasDigit(value) &&
      passwordHasSpecial(value);

  static String? passwordLive(String? value) {
    if (value == null || value.isEmpty) {
      return 'Заполните пароль';
    }
    final missing = <String>[];
    if (!passwordHasMinLength(value)) {
      missing.add('не меньше 8 символов');
    }
    if (!passwordHasDigit(value)) {
      missing.add('цифру');
    }
    if (!passwordHasSpecial(value)) {
      missing.add('спецсимвол (!@# и т.п.)');
    }
    if (missing.isEmpty) return null;
    return 'Нужны: ${missing.join(', ')}';
  }
}
