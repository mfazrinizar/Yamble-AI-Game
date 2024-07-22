class FormValidator {
  static String? validateEmail(String? value) {
    const locale = 'en';
    if (value == null || value.isEmpty) {
      return (locale == 'en'
          ? 'Please enter your email.'
          : 'Mohon masukkan email Anda.');
    } else if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value)) {
      return (locale == 'en'
          ? 'Please enter a valid email address.'
          : 'Mohon masukkan alamat email yang valid.');
    }
    return null;
  }

  static String? validatePassword(String? value) {
    const locale = 'en';

    if (value == null || value.isEmpty) {
      return (locale == 'en'
          ? 'Please enter your password.'
          : 'Mohon masukkan kata sandi Anda.');
    } else if (RegExp(r'^[0-9]+$').hasMatch(value)) {
      return (locale == 'en'
          ? 'Password must contains non-numerical character(s).'
          : 'Kata sandi harus mengandung karakter non-numerik.');
    } else if (value.length < 8) {
      return (locale == 'en'
          ? 'Password must be at least 8 characters long.'
          : 'Kata sandi harus memiliki panjang minimal 8 karakter.');
    }
    return null;
  }

  static String? validateRePassword(String? password, String? retypePassword) {
    const locale = 'en';
    if (retypePassword == null || retypePassword.isEmpty) {
      return locale == 'en'
          ? 'Please re-enter your password.'
          : 'Mohon masukkan ulang kata sandi Anda.';
    } else if (retypePassword != password) {
      return locale == 'en'
          ? 'Passwords do not match.'
          : 'Kata sandi tidak sama.';
    }
    return null;
  }

  static String? validateName(String? value) {
    const locale = 'en';
    if (value == null || value.isEmpty) {
      return locale == 'en'
          ? 'Please enter your name.'
          : 'Mohon masukkan nama Anda.';
    }
    return null;
  }

  static String? validateTitle(String? value) {
    const locale = 'en';
    if (value == null || value.isEmpty) {
      return locale == 'en'
          ? 'Please enter something.'
          : 'Mohon masukkan sesuatu.';
    } else if (value.length > 100) {
      return locale == 'en'
          ? 'Please enter the title no more than 100 characters.'
          : 'Mohon masukkan judul tidak lebih dari 100 karakter.';
    }
    return null;
  }

  static String? validateText(String? value) {
    const locale = 'en';
    if (value == null || value.isEmpty) {
      return locale == 'en'
          ? 'Please enter something.'
          : 'Mohon masukkan sesuatu.';
    }
    return null;
  }

  static String? validateUserName(String? value) {
    const locale = 'en';
    if (value == null || value.isEmpty) {
      return locale == 'en'
          ? 'Please enter your username.'
          : 'Mohon masukkan nama pengguna Anda.';
    } else if (value.length < 6) {
      return locale == 'en'
          ? 'Username must be at least 6 characters long.'
          : 'Nama pengguna harus memiliki panjang minimal 3 karakter.';
    } else if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return locale == 'en'
          ? 'Username can only contain alphabets and numbers.'
          : 'Nama pengguna hanya boleh berisi huruf dan angka.';
    } else if (value.length > 10) {
      return locale == 'en'
          ? 'Username must be at most 10 characters long.'
          : 'Nama pengguna harus memiliki panjang maksimal 10 karakter.';
    }
    return null;
  }
}
