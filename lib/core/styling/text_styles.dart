import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get heading1 =>
      GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark);
  static TextStyle get heading2 =>
      GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark);
  static TextStyle get heading3 =>
      GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark);
  static TextStyle get subtitle =>
      GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark);
  static TextStyle get body =>
      GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textDark);
  static TextStyle get bodySmall =>
      GoogleFonts.nunito(fontSize: 12.5, fontWeight: FontWeight.w400, color: AppColors.textMid);
  static TextStyle get label =>
      GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMid);
  static TextStyle get price =>
      GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink);
  static TextStyle get button =>
      GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink);
}
