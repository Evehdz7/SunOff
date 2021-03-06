import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sunoff/colors/light_colors.dart';
import 'package:sunoff/models/cotizacion/seccion_modelo.dart';

Widget cinputImage(BuildContext context, SeccionModelo section,
    Function(SeccionModelo) getImagen) {
  return StreamBuilder(
    stream: section.bloc.imagenStream,
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(MediaQuery.of(context).size.width, 40),
          primary: PColors.pLightBlue,
        ),
        onPressed: () => getImagen(section),
        child: Icon(
          Icons.add_a_photo,
        ),
      );
    },
  );
}
