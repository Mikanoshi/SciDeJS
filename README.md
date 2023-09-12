# SciDeJS

[![Get Delphi](https://img.shields.io/badge/Delphi-2009+%2032/64bit-ad1718?style=flat-square)](https://www.embarcadero.com/products/delphi)
[![Download Sciter](https://img.shields.io/badge/Sciter-%205.x-0077b6?style=flat-square)](https://sciter.com/download/)
[![Join Sciter forums](https://img.shields.io/badge/Forum-sciter.com-B5712D.svg?style=flat-square)](https://sciter.com/forums)

Minimal Sciter.JS bindings for Delphi.

## Installation
* Copy sciter.dll from [Sciter SDK](http://sciter.com/download/) to your exe directory (or define SCITER_DLL_DIR variable)
* Include SciterJS.pas and SciterJSAPI.pas units in your project, create TSciter class instance

## Embedding
TSciter constructor expects a window handle as a parameter to embed document into.<br>
If handle is not provided then invisible window will be created.<br>
Example of embedding Sciter as a Delphi component can be found in *SciterEmbedded.pas*
