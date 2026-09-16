import 'package:flutter_test/flutter_test.dart';
import 'package:fly_y/validation/validators.dart';

void main() {
  group('Обязательное поле', () {
    test('пустая строка отклоняется', () {
      expect(Validators.requiredField(''), isNotNull);
      expect(Validators.requiredField('   '), isNotNull);
    });

    test('непустая строка принимается', () {
      expect(Validators.requiredField('Солнце Антальи'), isNull);
    });
  });

  group('Почта', () {
    test('некорректный адрес отклоняется', () {
      expect(Validators.email('abc'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
    });

    test('корректный адрес принимается', () {
      expect(Validators.email('anna@mail.test'), isNull);
    });
  });

  group('Пароль при регистрации', () {
    test('короткий пароль без цифры и спецсимвола отклоняется', () {
      expect(Validators.passwordLive('abc'), isNotNull);
      expect(Validators.passwordLive('abcdefg1'), isNotNull);
      expect(Validators.passwordLive('abcdefgh!'), isNotNull);
    });

    test('сильный пароль принимается', () {
      expect(Validators.passwordLive('Pass123!'), isNull);
      expect(Validators.passwordStrong('Pass123!'), isTrue);
    });
  });

  group('Цена и код тура', () {
    test('цена выше лимита отклоняется', () {
      expect(Validators.price('300001'), isNotNull);
      expect(Validators.price('10000'), isNull);
    });

    test('код с кириллицей отклоняется', () {
      expect(Validators.tourCode('ТУ-2024'), isNotNull);
      expect(Validators.tourCode('TY-2024-001'), isNull);
    });
  });
}
