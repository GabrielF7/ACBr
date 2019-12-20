{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2009   Daniel Simoes de Almeida             }
{                                         Isaque Pinheiro                      }
{                                                                              }
{ Colaboradores nesse arquivo:                                                 }
{                                                                              }
{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do  Projeto ACBr    }
{ Componentes localizado em      http://www.sourceforge.net/projects/acbr      }
{                                                                              }
{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }
{                                                                              }
{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }
{                                                                              }
{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Daniel Sim�es de Almeida - daniel@projetoacbr.com.br - www.projetoacbr.com.br}
{       Rua Coronel Aureliano de Camargo, 963 - Tatu� - SP - 18270-170         }
{******************************************************************************}

unit ACBrInstallDelphiComponentes;

interface

uses
  SysUtils, Windows, Messages, Classes, Forms,
  JclIDEUtils, JclCompilerUtils, ACBrPacotes;

type
  TDestino = (tdSystem, tdDelphi, tdNone);

  TOnInformarSituacao = reference to procedure (const Mensagem: string);
  TOnProgresso  = TProc;

  TACBrInstallOpcoes = record
    LimparArquivosACBrAntigos: Boolean;
    DeixarSomentePastasLib: Boolean;
    DeveInstalarCapicom: Boolean;
    DeveInstalarOpenSSL: Boolean;
    DeveCopiarOutrasDLLs: Boolean;
    DeveInstalarXMLSec: Boolean;
    UsarCargaTardiaDLL: Boolean;
    RemoverStringCastWarnings: Boolean;
    UsarCpp: Boolean;
    UsarUsarArquivoConfig: Boolean;
    DiretorioRaizACBr: string;
  end;

  TACBrInstallComponentes = class(TObject)
  private
    FApp: TApplication;
    FOnProgresso: TOnProgresso;
    FOnInformaSituacao: TOnInformarSituacao;

    procedure FindDirs(InstalacaoAtual: TJclBorRADToolInstallation; APlatform:
        TJclBDSPlatform; ADirRoot: String; bAdicionar: Boolean = True);
    procedure CopiarArquivoDLLTo(ADestino : TDestino; const ANomeArquivo: String; const APathBin: string);

    procedure InstalarCapicom(ADestino : TDestino; const APathBin: string);
    procedure InstalarDiversos(ADestino: TDestino; const APathBin: string);
    procedure InstalarLibXml2(ADestino: TDestino; const APathBin: string);
    procedure InstalarOpenSSL(ADestino: TDestino; const APathBin: string);
    procedure InstalarXMLSec(ADestino: TDestino; const APathBin: string);

    procedure FazLog(const Texto:string);
    procedure InformaSituacao(const Mensagem: string);
    procedure InformaProgresso;

    function RetornaPath(const ADestino: TDestino; const APathBin: string): string;
    procedure RemoverPacotesAntigos;
    procedure RemoverDiretoriosACBrDoPath;
    procedure RemoverArquivosAntigosDoDisco;

    procedure AdicionaLibraryPathNaDelphiVersaoEspecifica(const APath: string; const AProcurarRemover: string);
    procedure AddLibrarySearchPath(const ADirLibrary: string);
    procedure DeixarSomenteLib;

    procedure CopiarOutrosArquivos(const ADirLibrary: string);
    procedure BeforeExecute(Sender: TJclBorlandCommandLineTool);
    procedure OutputCallLine(const Text: string);
    procedure CompilarPacotes(var FCountErros: Integer; const PastaACBr: string; listaPacotes: TPacotes);
    procedure InstalarPacotes(var FCountErros: Integer; const PastaACBr: string; listaPacotes: TPacotes);
  public
    Opcoes: TACBrInstallOpcoes;
    InstalacaoAtual: TJclBorRADToolInstallation;
    tPlatformAtual: TJclBDSPlatform;
    sDirLibrary: string;
    FPacoteAtual: TFileName;

    ArquivoLog: string;

    constructor Create(app: TApplication);

    procedure DesligarDefines;
    procedure FazInstalacaoInicial(const ADirLibrary: string);
    procedure InstalarOutrosRequisitos(const ADirLibrary: string);
    procedure CompilarEInstalarPacotes(var FCountErros: Integer; ListaPacotes: TPacotes);
    procedure FazInstalacaoDLLs(var FCountErros: Integer; ADestino : TDestino; const APathBin: string);


    property OnProgresso: TOnProgresso read FOnProgresso write FonProgresso;
    property OnInformaSituacao: TOnInformarSituacao read FOnInformaSituacao write FOnInformaSituacao;
  end;

implementation

uses
  ShellApi, Types, IOUtils,
  {IniFiles, StrUtils, Registry,
  JclCompilerUtils,
  Messages, FileCtrl, Variants, Graphics, Controls,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Buttons, pngimage, ShlObj,
  uFrameLista, UITypes,
  Types, JvComponentBase, JvCreateProcess, JvExControls, JvAnimatedImage,
  JvGIFCtrl, JvWizard, JvWizardRouteMapNodes, CheckLst
}
  ACBrUtil, ACBrInstallUtils;


procedure TACBrInstallComponentes.OutputCallLine(const Text: string);
begin
  // Evento disparado a cada a��o do compilador...

  // remover a warnings de convers�o de string (delphi 2010 em diante)
  // as diretivas -W e -H n�o removem estas mensagens
  if (pos('Warning: W1057', Text) <= 0) and ((pos('Warning: W1058', Text) <= 0)) then
  begin
    FazLog(Text);
  end;
end;

procedure TACBrInstallComponentes.BeforeExecute(Sender: TJclBorlandCommandLineTool);
var
  LArquivoCfg: TFilename;
begin
  // Evento para setar os par�metros do compilador antes de compilar

  // limpar os par�metros do compilador
  Sender.Options.Clear;

  // n�o utilizar o dcc32.cfg
  if (InstalacaoAtual.SupportsNoConfig) and
     // -- Arquivo cfg agora opcional no caso de paths muito extensos
     (not Opcoes.UsarUsarArquivoConfig) then
    Sender.Options.Add('--no-config');

  // -B = Build all units
  Sender.Options.Add('-B');
  // O+ = Optimization
  Sender.Options.Add('-$O-');
  // W- = Generate stack frames
  Sender.Options.Add('-$W+');
  // Y+ = Symbol reference info
  Sender.Options.Add('-$Y-');
  // -M = Make modified units
  Sender.Options.Add('-M');
  // -Q = Quiet compile
  Sender.Options.Add('-Q');
  // n�o mostrar warnings
  Sender.Options.Add('-H-');
  // n�o mostrar hints
  Sender.Options.Add('-W-');
  // -D<syms> = Define conditionals
  Sender.Options.Add('-DRELEASE');
  // -U<paths> = Unit directories
  Sender.AddPathOption('U', InstalacaoAtual.LibFolderName[tPlatformAtual]);
  Sender.AddPathOption('U', InstalacaoAtual.LibrarySearchPath[tPlatformAtual]);
  Sender.AddPathOption('U', sDirLibrary);
  // -I<paths> = Include directories
  Sender.AddPathOption('I', InstalacaoAtual.LibrarySearchPath[tPlatformAtual]);
  // -R<paths> = Resource directories
  Sender.AddPathOption('R', InstalacaoAtual.LibrarySearchPath[tPlatformAtual]);
  // -N0<path> = unit .dcu output directory
  Sender.AddPathOption('N0', sDirLibrary);
  Sender.AddPathOption('LE', sDirLibrary);
  Sender.AddPathOption('LN', sDirLibrary);

  // ************ C++ Builder *************** //
  if Opcoes.UsarCpp then
  begin
     // -JL compila c++ builder
     Sender.AddPathOption('JL', sDirLibrary);
     // -NO compila .dpi output directory c++ builder
     Sender.AddPathOption('NO', sDirLibrary);
     // -NB compila .lib output directory c++ builder
     Sender.AddPathOption('NB', sDirLibrary);
     // -NH compila .hpp output directory c++ builder
     Sender.AddPathOption('NH', sDirLibrary);
  end;

  // -- Path para instalar os pacotes do Rave no D7, nas demais vers�es
  // -- o path existe.
  if InstalacaoAtual.VersionNumberStr = 'd7' then
    Sender.AddPathOption('U', InstalacaoAtual.RootDir + '\Rave5\Lib');

  // -- Na vers�o XE2 por motivo da nova tecnologia FireMonkey, deve-se adicionar
  // -- os prefixos dos nomes, para identificar se ser� compilado para VCL ou FMX
  if InstalacaoAtual.VersionNumberStr = 'd16' then
    Sender.Options.Add('-NSData.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Bde;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell;System;Xml;Data;Datasnap;Web;Soap;Winapi;System.Win');

  if MatchText(InstalacaoAtual.VersionNumberStr, ['d17','d18','d19','d20','d21','d22','d23','d24','d25','d26']) then
    Sender.Options.Add('-NSWinapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Bde;System;Xml;Data;Datasnap;Web;Soap;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell');

  if (Opcoes.UsarUsarArquivoConfig) then
  begin
    LArquivoCfg := ChangeFileExt(FPacoteAtual, '.cfg');
    Sender.Options.SaveToFile(LArquivoCfg);
    Sender.Options.Clear;
  end;
end;

{ TACBrInstallComponentes }
constructor TACBrInstallComponentes.Create(app: TApplication);
begin
  inherited Create;
  //Valores padr�es das op��es
  Opcoes.LimparArquivosACBrAntigos := False;
  Opcoes.DeixarSomentePastasLib    := True;
  Opcoes.DeveInstalarCapicom       := False;
  Opcoes.DeveInstalarOpenSSL       := True;
  Opcoes.DeveCopiarOutrasDLLs      := True;
  Opcoes.DeveInstalarXMLSec        := False;
  Opcoes.UsarCargaTardiaDLL        := False;
  Opcoes.RemoverStringCastWarnings := False;
  Opcoes.UsarCpp                   := False;
  Opcoes.UsarUsarArquivoConfig     := True;
  Opcoes.DiretorioRaizACBr         := 'C:\ACBr\';

  ArquivoLog := '';

  FApp := app;
end;


procedure TACBrInstallComponentes.DeixarSomenteLib;
begin
  // remover os path com o segundo parametro
  FindDirs(InstalacaoAtual, tPlatformAtual, Opcoes.DiretorioRaizACBr + 'Fontes', False);
end;

procedure TACBrInstallComponentes.FazInstalacaoInicial(const ADirLibrary: string);
begin
  // -- Evento disparado antes de iniciar a execu��o do processo.
  InstalacaoAtual.DCC32.OnBeforeExecute := BeforeExecute;
  // -- Evento para saidas de mensagens.
  InstalacaoAtual.OutputCallback := OutputCallLine;


  if Opcoes.LimparArquivosACBrAntigos then
  begin
    InformaSituacao('Removendo arquivos ACBr antigos dos discos...');
    RemoverArquivosAntigosDoDisco;
    InformaSituacao('...OK');
    InformaProgresso;
  end;

  InformaSituacao('Removendo instala��o anterior do ACBr na IDE...');
  RemoverDiretoriosACBrDoPath;
  RemoverPacotesAntigos;


  InformaSituacao('...OK');
  InformaProgresso;

  // *************************************************************************
  // Cria diret�rio de biblioteca da vers�o do delphi selecionada,
  // s� ser� criado se n�o existir
  // *************************************************************************
  InformaSituacao('Criando diret�rios de bibliotecas...');
  ForceDirectories(ADirLibrary);
  InformaSituacao('...OK');
  InformaProgresso;

  // *************************************************************************
  // Adiciona os paths dos fontes na vers�o do delphi selecionada
  // *************************************************************************
  InformaSituacao('Adicionando library paths...');
  AddLibrarySearchPath(ADirLibrary);
  InformaSituacao('...OK');
  InformaProgresso;

end;

procedure TACBrInstallComponentes.FazLog(const Texto: string);
begin
  if ArquivoLog <> EmptyStr then
    WriteToTXT(ArquivoLog, Texto);
end;

function TACBrInstallComponentes.RetornaPath(const ADestino: TDestino; const APathBin: string): string;
begin
  case ADestino of
    tdSystem: Result := '"'+ PathSystem + '"';
    tdDelphi: Result := '"'+ APathBin + '"';
    tdNone:   Result := 'Tipo de destino "nenhum" n�o aceito!';
  else
    Result := 'Tipo de destino desconhecido!'
  end;
end;

procedure TACBrInstallComponentes.FazInstalacaoDLLs(var FCountErros: Integer; ADestino : TDestino; const APathBin: string);
begin
  // *************************************************************************
  // instalar capicom
  // *************************************************************************
  try
    if Opcoes.DeveInstalarCapicom then
    begin
      InstalarCapicom(ADestino, APathBin);
      InformaSituacao('CAPICOM instalado com sucesso em '+ RetornaPath(ADestino, APathBin));
    end;
  except
    on E: Exception do
    begin
      Inc(FCountErros);
      InformaSituacao('Ocorreu erro ao instalar a CAPICOM em '+ RetornaPath(ADestino, APathBin) + sLineBreak +
            'Erro: ' + E.Message);
    end;
  end;
  // *************************************************************************
  // instalar OpenSSL
  // *************************************************************************
  try
    if Opcoes.DeveInstalarOpenSSL then
    begin
      InstalarOpenSSL(ADestino, APathBin);
      InformaSituacao('OPENSSL instalado com sucesso em '+ RetornaPath(ADestino, APathBin));
    end;
  except
    on E: Exception do
    begin
      Inc(FCountErros);
      InformaSituacao('Ocorreu erro ao instalar a OPENSSL em '+ RetornaPath(ADestino, APathBin) + sLineBreak +
            'Erro: ' + E.Message);
    end;
  end;
  // *************************************************************************
  //instalar todas as "OUTRAS" DLLs
  // *************************************************************************
  if Opcoes.DeveCopiarOutrasDLLs then
  begin
    try
      InstalarLibXml2(ADestino, APathBin);
      InformaSituacao('LibXml2 instalado com sucesso em '+ RetornaPath(ADestino, APathBin));

      InstalarDiversos(ADestino, APathBin);
      InformaSituacao('DLLs diversas instalado com sucesso em '+ RetornaPath(ADestino, APathBin));

      if Opcoes.DeveInstalarXMLSec then
      begin
        InstalarXMLSec(ADestino, APathBin);
        InformaSituacao('XMLSec instalado com sucesso em '+ RetornaPath(ADestino, APathBin));
      end;
    except
      on E: Exception do
      begin
        Inc(FCountErros);
        InformaSituacao('Ocorreu erro ao instalar Outras DLL�s em '+ RetornaPath(ADestino, APathBin) + sLineBreak +
              'Erro: ' + E.Message);
      end;
    end;
  end;
end;

procedure TACBrInstallComponentes.InformaProgresso;
begin
  if Assigned(FOnProgresso) then
    FOnProgresso;
end;

procedure TACBrInstallComponentes.FindDirs(InstalacaoAtual: TJclBorRADToolInstallation;
    APlatform: TJclBDSPlatform; ADirRoot: String; bAdicionar: Boolean = True);

  function ExisteArquivoPasNoDir(const ADir: string): Boolean;
  var
    oDirList: TSearchRec;
  begin
    Result := False;
    if FindFirst(ADir + '*.pas', faNormal, oDirList) = 0 then
    begin
      try
        Result := True;
      finally
        SysUtils.FindClose(oDirList)
      end;
    end;
  end;

  function EProibido(const ADir: String): Boolean;
  const
    LISTA_PROIBIDOS: ARRAY[0..14] OF STRING = (
      'quick', 'rave', 'laz', 'VerificarNecessidade', '__history', '__recovery', 'backup',
      'Logos', 'Colorido', 'PretoBranco', 'Imagens', 'bmp', 'logotipos', 'PerformanceTest', 'test'
    );
  var
    Str: String;
  begin
//    Result := False;
    for str in LISTA_PROIBIDOS do
    begin
      Result := Pos(AnsiUpperCase(str), AnsiUpperCase(ADir)) > 0;
      if Result then
        Break;
    end;
  end;

var
  oDirList: TSearchRec;
begin
  ADirRoot := IncludeTrailingPathDelimiter(ADirRoot);
  
  if FindFirst(ADirRoot + '*.*', faDirectory, oDirList) = 0 then
  begin
    try
      repeat
        if ((oDirList.Attr and faDirectory) <> 0) and
            (oDirList.Name <> '.')                and
            (oDirList.Name <> '..') then
        begin
          if not bAdicionar then
          begin
            InstalacaoAtual.RemoveFromLibrarySearchPath(ADirRoot + oDirList.Name, APlatform);
          end
          else
          begin
            if (not EProibido(oDirList.Name)) then
            begin
              if ExisteArquivoPasNoDir(oDirList.Name) then
              begin
                InstalacaoAtual.AddToLibrarySearchPath(ADirRoot + oDirList.Name, APlatform);
                InstalacaoAtual.AddToLibraryBrowsingPath(ADirRoot + oDirList.Name, APlatform);
              end;
              //-- Procura subpastas
              FindDirs(InstalacaoAtual, APlatform, ADirRoot + oDirList.Name, bAdicionar);
            end;
          end;
        end;
      until FindNext(oDirList) <> 0;
    finally
      SysUtils.FindClose(oDirList)
    end;
  end;
end;

procedure TACBrInstallComponentes.AddLibrarySearchPath(const ADirLibrary: string);
var
  InstalacaoAtualCpp: TJclBDSInstallation;
begin
// adicionar o paths ao library path do delphi

  FindDirs(InstalacaoAtual, tPlatformAtual, Opcoes.DiretorioRaizACBr + 'Fontes');

  InstalacaoAtual.AddToLibraryBrowsingPath(ADirLibrary, tPlatformAtual);
  InstalacaoAtual.AddToLibrarySearchPath(ADirLibrary, tPlatformAtual);
  InstalacaoAtual.AddToDebugDCUPath(ADirLibrary, tPlatformAtual);

  // -- adicionar a library path ao path do windows

  AdicionaLibraryPathNaDelphiVersaoEspecifica(ADirLibrary, 'acbr');

  //-- ************ C++ Builder *************** //
  if Opcoes.UsarCpp then
  begin
     if InstalacaoAtual is TJclBDSInstallation then
     begin
       InstalacaoAtualCpp := TJclBDSInstallation(InstalacaoAtual);
       InstalacaoAtualCpp.AddToCppSearchPath(ADirLibrary, tPlatformAtual);
       InstalacaoAtualCpp.AddToCppLibraryPath(ADirLibrary, tPlatformAtual);
       InstalacaoAtualCpp.AddToCppBrowsingPath(ADirLibrary, tPlatformAtual);
       InstalacaoAtualCpp.AddToCppIncludePath(ADirLibrary, tPlatformAtual);
     end;
  end;
end;

procedure TACBrInstallComponentes.RemoverDiretoriosACBrDoPath();
var
  ListaPaths: TStringList;
  I: Integer;
begin
  ListaPaths := TStringList.Create;
  try
    ListaPaths.StrictDelimiter := True;
    ListaPaths.Delimiter := ';';

    // remover do search path
    ListaPaths.Clear;
    ListaPaths.DelimitedText := InstalacaoAtual.RawLibrarySearchPath[tPlatformAtual];
    for I := ListaPaths.Count - 1 downto 0 do
    begin
      if Pos('ACBR', AnsiUpperCase(ListaPaths[I])) > 0 then
        ListaPaths.Delete(I);
    end;
    InstalacaoAtual.RawLibrarySearchPath[tPlatformAtual] := ListaPaths.DelimitedText;
    // remover do browse path
    ListaPaths.Clear;
    ListaPaths.DelimitedText := InstalacaoAtual.RawLibraryBrowsingPath[tPlatformAtual];
    for I := ListaPaths.Count - 1 downto 0 do
    begin
      if Pos('ACBR', AnsiUpperCase(ListaPaths[I])) > 0 then
        ListaPaths.Delete(I);
    end;
    InstalacaoAtual.RawLibraryBrowsingPath[tPlatformAtual] := ListaPaths.DelimitedText;
    // remover do Debug DCU path
    ListaPaths.Clear;
    ListaPaths.DelimitedText := InstalacaoAtual.RawDebugDCUPath[tPlatformAtual];
    for I := ListaPaths.Count - 1 downto 0 do
    begin
      if Pos('ACBR', AnsiUpperCase(ListaPaths[I])) > 0 then
        ListaPaths.Delete(I);
    end;
    InstalacaoAtual.RawDebugDCUPath[tPlatformAtual] := ListaPaths.DelimitedText;
  finally
    ListaPaths.Free;
  end;
end;

procedure TACBrInstallComponentes.RemoverPacotesAntigos;
var
  I: Integer;
begin
  // remover pacotes antigos
  for I := InstalacaoAtual.IdePackages.Count - 1 downto 0 do
  begin
    if Pos('ACBR', AnsiUpperCase(InstalacaoAtual.IdePackages.PackageFileNames[I])) > 0 then
      InstalacaoAtual.IdePackages.RemovePackage(InstalacaoAtual.IdePackages.PackageFileNames[I]);
  end;
end;

procedure TACBrInstallComponentes.CopiarArquivoDLLTo(ADestino : TDestino; const ANomeArquivo: String;
     const APathBin: string);
var
  PathOrigem: String;
  PathDestino: String;
  DirSystem: String;

begin
  case ADestino of
    tdSystem: DirSystem := Trim(PathSystem);
    tdDelphi: DirSystem := APathBin;
  end;

  if DirSystem <> EmptyStr then
    DirSystem := IncludeTrailingPathDelimiter(DirSystem)
  else
    raise EFileNotFoundException.Create('Diret�rio de sistema n�o encontrado.');

  PathOrigem  := Opcoes.DiretorioRaizACBr + 'DLLs\' + ANomeArquivo;
  PathDestino := DirSystem + ExtractFileName(ANomeArquivo);

  if FileExists(PathOrigem) and not(FileExists(PathDestino)) then
  begin
    if not CopyFile(PWideChar(PathOrigem), PWideChar(PathDestino), True) then
    begin
      raise EFilerError.CreateFmt(
        'Ocorreu o seguinte erro ao tentar copiar o arquivo "%s": %d - %s', [
        ANomeArquivo, GetLastError, SysErrorMessage(GetLastError)
      ]);
    end;
  end;
end;

procedure TACBrInstallComponentes.InformaSituacao(const Mensagem: string);
begin
  FazLog(Mensagem);

  if Assigned(OnInformaSituacao) then
    OnInformaSituacao(Mensagem);
end;

procedure TACBrInstallComponentes.InstalarCapicom(ADestino : TDestino; const APathBin: string);
begin
// copia as dlls da pasta capcom para a pasta escolhida pelo usuario e registra a dll
  if ADestino <> tdNone then
  begin
    CopiarArquivoDLLTo(ADestino, 'Capicom\capicom.dll', APathBin);
    CopiarArquivoDLLTo(ADestino, 'Capicom\msxml5.dll',  APathBin);
    CopiarArquivoDLLTo(ADestino, 'Capicom\msxml5r.dll', APathBin);

    if ADestino = tdDelphi then
    begin
      RegistrarActiveXServer(APathBin + 'capicom.dll', True);
      RegistrarActiveXServer(APathBin + 'msxml5.dll', True);
    end
    else
    begin
      RegistrarActiveXServer('capicom.dll', True);
      RegistrarActiveXServer('msxml5.dll', True);
    end;
  end;
end;

//copia as dlls da pasta Diversoso para a pasta escolhida pelo usuario
procedure TACBrInstallComponentes.InstalarDiversos(ADestino: TDestino; const APathBin: string);
begin
  if ADestino <> tdNone then
  begin
    CopiarArquivoDLLTo(ADestino,'Diversos\iconv.dll',    APathBin);
    CopiarArquivoDLLTo(ADestino,'Diversos\inpout32.dll', APathBin);
    CopiarArquivoDLLTo(ADestino,'Diversos\msvcr71.dll',  APathBin);
  end;
end;

procedure TACBrInstallComponentes.InstalarLibXml2(ADestino: TDestino; const APathBin: string);
begin
  if ADestino <> tdNone then
  begin
    CopiarArquivoDLLTo(ADestino,'LibXml2\x86\libxslt.dll',  APathBin);
    CopiarArquivoDLLTo(ADestino,'LibXml2\x86\libexslt.dll', APathBin);
    CopiarArquivoDLLTo(ADestino,'LibXml2\x86\libiconv.dll', APathBin);
    CopiarArquivoDLLTo(ADestino,'LibXml2\x86\libxml2.dll',  APathBin);
  end;
end;

procedure TACBrInstallComponentes.InstalarOpenSSL(ADestino: TDestino; const APathBin: string);
begin
// copia as dlls da pasta openssl, estas dlls s�o utilizadas para assinar
// arquivos e outras coisas mais
  if ADestino <> tdNone then
  begin
    CopiarArquivoDLLTo(ADestino,'OpenSSL\1.0.2.20\x86\libeay32.dll', APathBin);
    CopiarArquivoDLLTo(ADestino,'OpenSSL\1.0.2.20\x86\ssleay32.dll', APathBin);
  end;
end;

procedure TACBrInstallComponentes.InstalarOutrosRequisitos(const ADirLibrary: string);
begin
  InformaSituacao(sLineBreak+'INSTALANDO OUTROS REQUISITOS...');
  // *************************************************************************
  // deixar somente a pasta lib se for configurado assim
  // *************************************************************************
  if Opcoes.DeixarSomentePastasLib then
  begin
    try
      DeixarSomenteLib;
      InformaSituacao('Limpeza library path com sucesso');
    except
      on E: Exception do
      begin
        InformaSituacao('Ocorreu erro ao limpar o path: ' + sLineBreak + E.Message);
      end;
    end;
    try
      CopiarOutrosArquivos(ADirLibrary);
      InformaSituacao('C�pia dos arquivos necess�rio feita com sucesso para: '+ ADirLibrary);
    except
      on E: Exception do
      begin
        InformaSituacao('Ocorreu erro ao copiar arquivos para: '+ ADirLibrary + sLineBreak +
              'Erro:'+ E.Message);
      end;
    end;
  end;
end;

procedure TACBrInstallComponentes.InstalarXMLSec(ADestino: TDestino; const APathBin: string);
begin
//copia as dlls da pasta XMLSec para a pasta escolhida pelo usuario
  if ADestino <> tdNone then
  begin
    CopiarArquivoDLLTo(ADestino, 'XMLSec\iconv.dll', APathBin);
    CopiarArquivoDLLTo(ADestino, 'XMLSec\libxml2.dll', APathBin);
    CopiarArquivoDLLTo(ADestino, 'XMLSec\libxmlsec.dll', APathBin);
    CopiarArquivoDLLTo(ADestino, 'XMLSec\libxmlsec-openssl.dll', APathBin);
    CopiarArquivoDLLTo(ADestino, 'XMLSec\libxslt.dll', APathBin);
    CopiarArquivoDLLTo(ADestino, 'XMLSec\zlib1.dll', APathBin);
  end;
end;

procedure TACBrInstallComponentes.AdicionaLibraryPathNaDelphiVersaoEspecifica(const APath: string; const
    AProcurarRemover: string);
var
  PathsAtuais: string;
  ListaPaths: TStringList;
  I: Integer;
  wParam: Integer;
  lParam: Integer;
  lpdwResult: PDWORD_PTR;
  Resultado: Integer;
const
  cs: PChar = 'Environment Variables';
begin
  // tentar ler o path configurado na ide do delphi, se n�o existir ler
  // a atual para complementar e fazer o override
  PathsAtuais := Trim(InstalacaoAtual.EnvironmentVariables.Values['PATH']);
  if PathsAtuais = '' then
    PathsAtuais := GetEnvironmentVariable('PATH');
  // manipular as strings
  ListaPaths := TStringList.Create;
  try
    ListaPaths.Clear;
    ListaPaths.Delimiter := ';';
    ListaPaths.StrictDelimiter := True;
    ListaPaths.DelimitedText := PathsAtuais;
    // verificar se existe algo do ACBr e remover do environment variable PATH do delphi
    if Trim(AProcurarRemover) <> '' then
    begin
      for I := ListaPaths.Count - 1 downto 0 do
      begin
        if Pos(AnsiUpperCase(AProcurarRemover), AnsiUpperCase(ListaPaths[I])) > 0 then
          ListaPaths.Delete(I);
      end;
    end;
    // adicionar o path
    ListaPaths.Add(APath);
    // escrever a variavel no override da ide
    InstalacaoAtual.ConfigData.WriteString(cs, 'PATH', ListaPaths.DelimitedText);
    // enviar um broadcast de atualiza��o para o windows
    wParam := 0;
    lParam := LongInt(cs);
    lpdwResult := NIL;
    Resultado := SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, wParam, lParam, SMTO_NORMAL, 4000, lpdwResult);
    if Resultado = 0 then
      raise Exception.create('Ocorreu um erro ao tentar configurar o path: ' + SysErrorMessage(GetLastError));
  finally
    ListaPaths.Free;
  end;
end;

procedure TACBrInstallComponentes.CopiarOutrosArquivos(const ADirLibrary: string);
  procedure Copiar(const Extensao : string);
  var
    ListArquivos: TStringDynArray;
    Arquivo : string;
    i: integer;
  begin
    ListArquivos := TDirectory.GetFiles(Opcoes.DiretorioRaizACBr + 'Fontes', Extensao, TSearchOption.soAllDirectories ) ;
    for i := Low(ListArquivos) to High(ListArquivos) do
    begin
      Arquivo := ExtractFileName(ListArquivos[i]);
      CopyFile(PWideChar(ListArquivos[i]), PWideChar(IncludeTrailingPathDelimiter(ADirLibrary) + Arquivo), False);
    end;
  end;
begin
  Copiar('*.dcr');
  Copiar('*.res');
  Copiar('*.dfm');
  Copiar('*.ini');
  Copiar('*.inc');
end;

procedure TACBrInstallComponentes.DesligarDefines;
var
  ArquivoACBrInc: TFileName;
begin
  ArquivoACBrInc := Opcoes.DiretorioRaizACBr + 'Fontes\ACBrComum\ACBr.inc';
  DesligarDefineACBrInc(ArquivoACBrInc, 'DFE_SEM_OPENSSL', not Opcoes.DeveInstalarOpenSSL);
  DesligarDefineACBrInc(ArquivoACBrInc, 'DFE_SEM_CAPICOM', not Opcoes.DeveInstalarCapicom);
  DesligarDefineACBrInc(ArquivoACBrInc, 'USE_DELAYED', Opcoes.UsarCargaTardiaDLL);
  DesligarDefineACBrInc(ArquivoACBrInc, 'REMOVE_CAST_WARN', Opcoes.RemoverStringCastWarnings);
  DesligarDefineACBrInc(ArquivoACBrInc, 'DFE_SEM_XMLSEC', not Opcoes.DeveInstalarXMLSec);

end;
procedure TACBrInstallComponentes.RemoverArquivosAntigosDoDisco;
var
  PathBat: String;
  DriverList: TStringList;
  ConteudoArquivo: String;
  I: Integer;
begin
  PathBat := ExtractFilePath(ParamStr(0)) + 'apagarACBr.bat';

  // listar driver para montar o ConteudoArquivo
  DriverList := TStringList.Create;
  try
    GetDriveLetters(DriverList);
    ConteudoArquivo := '@echo off' + sLineBreak;
    for I := 0 to DriverList.Count -1 do
    begin
      ConteudoArquivo := ConteudoArquivo + StringReplace(DriverList[I], '\', '', []) + sLineBreak;
      ConteudoArquivo := ConteudoArquivo + 'cd\' + sLineBreak;
      ConteudoArquivo := ConteudoArquivo + 'del ACBr*.bpl ACBr*.dcp ACBr*.dcu PCN*.bpl PCN*.dcp PCN*.dcu SYNA*.bpl SYNA*.dcp SYNA*.dcu pnfs*.dcu pcte*.bpl pcte*.dcp pcte*.dcu pmdfe*.bpl pmdfe*.dcp pmdfe*.dcu pgnre*.dcp pgnre*.dcu pces*.dcp pces*.dcu pca*.dcp pca*.dcu /s' + sLineBreak;
      ConteudoArquivo := ConteudoArquivo + sLineBreak;
    end;

    WriteToTXT(PathBat, ConteudoArquivo, False);
  finally
    DriverList.Free;
  end;

  RunAsAdminAndWaitForCompletion(FApp.Handle, PathBat, FApp);
end;

procedure TACBrInstallComponentes.CompilarEInstalarPacotes(var FCountErros: Integer; ListaPacotes: TPacotes);
begin
  // *************************************************************************
  // compilar os pacotes primeiramente
  // *************************************************************************
  InformaSituacao(sLineBreak+'COMPILANDO OS PACOTES...');
  CompilarPacotes(FCountErros, Opcoes.DiretorioRaizACBr, ListaPacotes);

  // *************************************************************************
  // instalar os pacotes somente se n�o ocorreu erro na compila��o e plataforma for Win32
  // *************************************************************************
  if FCountErros > 0 then
  begin
    InformaSituacao('Abortando... Ocorreram erros na compila��o dos pacotes.');
    Exit;
  end;

  if ( tPlatformAtual = bpWin32) then
  begin
    InformaSituacao(sLineBreak+'INSTALANDO OS PACOTES...');
    InstalarPacotes(FCountErros, Opcoes.DiretorioRaizACBr, ListaPacotes);
  end
  else
  begin
    InformaSituacao('Para a plataforma de 64 bits os pacotes s�o somente compilados.');
  end;

end;


procedure TACBrInstallComponentes.CompilarPacotes(var FCountErros: Integer;
      const PastaACBr: string; listaPacotes: TPacotes);
var
  iDpk: Integer;
  NomePacote: string;
  sDirPackage: string;
begin
  for iDpk := 0 to listaPacotes.Count - 1 do
  begin
    if (not listaPacotes[iDpk].Checked) then
    begin
      InformaProgresso;
      Continue;
    end;

    NomePacote := listaPacotes[iDpk].Caption;
    // Busca diret�rio do pacote
    sDirPackage := FindDirPackage(IncludeTrailingPathDelimiter(PastaACBr) + 'Pacotes\Delphi', NomePacote);
    if (IsDelphiPackage(NomePacote)) then
    begin
      FazLog('');
      FPacoteAtual := sDirPackage + NomePacote;
      if InstalacaoAtual.CompilePackage(sDirPackage + NomePacote, sDirLibrary, sDirLibrary) then
        InformaSituacao(Format('Pacote "%s" compilado com sucesso.', [NomePacote]))
      else
      begin
        Inc(FCountErros);
        InformaSituacao(Format('Erro ao compilar o pacote "%s".', [NomePacote]));
        // parar no primeiro erro para evitar de compilar outros pacotes que
        // precisam do pacote que deu erro
        Break;
      end;
    end;
    InformaProgresso;
  end;
end;

procedure TACBrInstallComponentes.InstalarPacotes(var FCountErros: Integer;
      const PastaACBr: string; listaPacotes: TPacotes);
var
  iDpk: Integer;
  NomePacote: string;
  bRunOnly: Boolean;
  sDirPackage: string;
begin
  for iDpk := 0 to listaPacotes.Count - 1 do
  begin
    NomePacote := listaPacotes[iDpk].Caption;
    // Busca diret�rio do pacote
    sDirPackage := FindDirPackage(IncludeTrailingPathDelimiter(PastaACBr) + 'Pacotes\Delphi', NomePacote);
    if IsDelphiPackage(NomePacote) then
    begin
      FPacoteAtual := sDirPackage + NomePacote;
      // instalar somente os pacotes de designtime
      GetDPKFileInfo(sDirPackage + NomePacote, bRunOnly);
      if not bRunOnly then
      begin
        // se o pacote estiver marcado instalar, sen�o desinstalar
        if listaPacotes[iDpk].Checked then
        begin
          if InstalacaoAtual.InstallPackage(sDirPackage + NomePacote, sDirLibrary, sDirLibrary) then
            InformaSituacao(Format('Pacote "%s" instalado com sucesso.', [NomePacote]))
          else
          begin
            Inc(FCountErros);
            InformaSituacao(Format('Ocorreu um erro ao instalar o pacote "%s".', [NomePacote]));
            Break;
          end;
        end
        else
        begin
          if InstalacaoAtual.UninstallPackage(sDirPackage + NomePacote, sDirLibrary, sDirLibrary) then
            InformaSituacao(Format('Pacote "%s" removido com sucesso...', [NomePacote]));
        end;
      end;
    end;
    InformaProgresso;
  end;
end;




end.