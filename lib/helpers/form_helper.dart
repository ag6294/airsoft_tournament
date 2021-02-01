class FormHelper {
  static String validateEmail(String text) {
    String isValid;

    if (text == null || text == '') {
      isValid = 'Inserisci un\'email';
    } else if (!text.contains('@') || !text.contains('.')) {
      isValid = 'Inserisci un\'email valida';
    }

    return isValid;
  }

  static String validatePassword(String text, [String teamPwd]) {
    String isValid;

    if (text == null || text == '')
      isValid = 'Inserisci una password';
    else if (teamPwd != null && teamPwd != '') if (teamPwd.compareTo(text) != 0)
      isValid = 'Pasword del team sbagliata';
    else if (text.length < 6)
      isValid = 'Inserisci una password di almeno 6 lettere';

    return isValid;
  }

  static String validatePassword2(String text1, String text2) {
    String isValid;

    if (text1 == null || text1 == '')
      isValid = 'Inserisci una password';
    else if (text1.length < 6)
      isValid = 'Inserisci una password di almeno 6 lettere';
    else if (text2.compareTo(text1) != 0)
      isValid = 'Le password devono coincidere';

    return isValid;
  }

  static String validateNickname(String text1) {
    String isValid;

    if (text1 == null || text1 == '') isValid = 'Inserisci un nickname';

    return isValid;
  }

  static String validateGenericText(String text1) {
    String isValid;

    if (text1 == null || text1 == '') isValid = 'Compila questo campo';

    return isValid;
  }
}
