import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

abstract class MangerEvent extends Equatable{
  const MangerEvent();

  @override
  List<Object> get props => [];
}

class ResturantEvent extends MangerEvent {
  final String resturant_name;
  final String resturant_phone;
  final PlatformFile? logo_image;
  final PlatformFile verification_docs;
  final PlatformFile?  cover_image;
  

  const ResturantEvent({
  
   required this.resturant_name,
   required this.resturant_phone,
   this.logo_image,
   required this.verification_docs,
   this.cover_image,
  });

  @override
  List<Object> get props => [
        resturant_name,
        resturant_phone,
        logo_image ?? Image.asset('logo.png'),
        verification_docs,
        cover_image ?? Image.asset('logo.png'),
        
      ];
}

