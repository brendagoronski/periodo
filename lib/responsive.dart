import 'package:flutter/widgets.dart';

/// Arquivo utilitário com helpers de responsividade do app.
/// Define breakpoints e funções para largura máxima e padding adaptativo.
const double kMobileBreakpoint = 600;
const double kTabletBreakpoint = 1024;

/// Retorna verdadeiro quando a largura é considerada de um layout mobile.
bool isMobile(double width) => width < kMobileBreakpoint;

/// Retorna verdadeiro quando a largura corresponde a um layout de tablet.
bool isTablet(double width) => width >= kMobileBreakpoint && width < kTabletBreakpoint;

/// Retorna verdadeiro quando a largura corresponde a um layout desktop.
bool isDesktop(double width) => width >= kTabletBreakpoint;

/// Largura máxima sugerida para o conteúdo central em telas amplas.
/// - Mobile: ocupa toda a largura
/// - Tablet: limita a ~800
/// - Desktop: limita a ~1000
double getMaxContentWidth(double width) {
  if (isMobile(width)) return width; // ocupar toda largura no mobile
  if (isTablet(width)) return 800;
  return 1000; // desktop
}

/// Padding horizontal/vertical sugerido por largura de tela.
/// Mantém espaçamentos coerentes entre mobile, tablet e desktop.
EdgeInsets getPagePadding(double width) {
  if (isMobile(width)) return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  if (isTablet(width)) return const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
  return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
} 