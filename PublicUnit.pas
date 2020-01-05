unit PublicUnit;

interface

uses Windows, Messages, SysUtils, Classes, ExtCtrls,  Graphics, Controls, Forms,
     stdctrls, iEdit, iAnalogOutput, IniFiles,  NI_Delphi, iXYPlot, EController;

type
  TSensor = class
  private
    DataBuf:array[0..500]of single;
    BufCount:Integer;
  public
    K,B:single;
    off:Single;
    Value,Voltage:Single;
    Constructor Create(count:integer=60);

    {
    procedure SaveToFile(filestream:TFileStream);
    procedure LoadFromFile(filestream:TFileStream);
    procedure SetToEdit(Edit1,Edit2:TControl);
    procedure GetFromEdit(Edit1,Edit2:TControl);
    procedure Sample; overload;
    }
    procedure Sample(Value:Single);
    function GetData(Kind:String):single;
  end;

  TDataFilter = class
  private
    Buf:array[0..500]of single;
    Index: Integer;
  public
    FilterCount: integer;
    Value:Single;
    Constructor Create(Count:Integer);
    function GetData(v:Single):Single;
    procedure Clear;

  end;



function GetDataFromString(str:String; var Data:array of single; c:char=' '):integer;
function GetStrFromString(str:String; var Data:array of string; c:char=' '):integer;
procedure SaveFile(ch:Integer);
procedure SaveAllDataFile(ch:Integer);

{
var LF_Door,RF_Door,LB_Door,RB_Door:TMovement;
    FR_Cover,BK_Cover:TMovement;
    DO_Dev:TNI_DO;
    DI_Dev:TNI_DI;
    }

var NI_AD: TNI_AD;
    NI_DA: TNI_DA;
    SetupFile: TIniFile;
    DataBuf:array[0..1,0..5,0..2000000]of Single;
    AllDataBuf:array[0..1,0..2,0..2000000]of single;
    DataBufCount,AllDataBufCount:array[0..1] of Integer;
    RunMaxCount, HistoryCount,NowRunCount,LastRunCount:array[0..1] of Integer;  //RunMaxCount是设定总次数,Historyount是已经跑过的次数，ThisRunCount是这一次跑的次数
    AveMaxTorque,AveMinTorque,MaxTorque,MinTorque,SumMaxTorque,SumMinTorque:array[0..1] of Single;
    //AveMaxTorque是初始10个周期的最大平均扭矩，MaxTorque是每一个周期的最大扭矩，SumMaxTorque是前十个周期最大扭矩的和
    MaxAngle,MinAngle:array[0..1] of Single;
    NowAngle,NowTorque:array[0..1] of Single;
    AngleOff,AngleGain,TorqueOff,TorqueGain:array[0..1] of Single;
    JudgeMaxTorque,JudgeMinTorque,JudgeMaxAngle,JudgeMinAngle: array[0..1,0..9] of Single;
    GetTorqueNumber,GetTorqueIndex:array[0..1] of Integer;
    JudgeFreCount:array[0..1] of Integer;      //自动停机判断中用来判断周期次数判断。
    GetAveTorque:array[0..1] of Boolean;  //每次开始之后  取10个周期的扭矩的标志位
    MaxTorqueOff,MinTorqueOff:array[0..1] of Single;
    MyTimer:array[0..1] of TMyTimer;
    


const MaxCHNum=4;
      MaxSaveTime=300;
    
implementation



function GetDataFromString(str:String; var Data:array of single; c:char):integer;
var strdata: array[0..20] of string;
    i:integer;
begin
  Result:=GetStrFromString(Str,strdata,c);
  for i:=0 to Result-1 do
    Data[i]:=StrToFloat(strdata[i]);
end;

function GetStrFromString(str:String; var Data:array of string; c:char):integer;
begin
  str:=trim(str);
  Result:=0;
  if str='' then Exit;

  while Pos(c,Str)>0 do
  begin
    data[Result]:=copy(Str,1,Pos(c,Str)-1);
    delete(Str,1,Pos(c,Str));
    Inc(Result);
  end;
  Data[Result]:=Str;
  Result:=Result+1;
end;

Constructor TSensor.Create(count:integer);
begin
  BufCount:=count;
  K:=1; B:=0;
end;

{
procedure TSensor.SaveToFile(filestream:TFileStream);
begin
  filestream.Write(K,sizeof(single));
  filestream.Write(B,sizeof(single));
end;

procedure TSensor.SetToEdit(Edit1,Edit2:TControl);
begin
  if Edit1.ClassName='TEdit' then
  begin
    (Edit1 as TEdit).Text:=Format('%.3f',[K]);
    (Edit2 as TEdit).Text:=Format('%.3f',[B]);
  end
  else if Edit1.ClassName='TiEdit' then
  begin
    (Edit1 as TiEdit).Value:=Format('%.3f',[K]);
    (Edit2 as TiEdit).Value:=Format('%.3f',[B]);
  end
  else if Edit1.ClassName='TiAnalogOutput' then
  begin
    (Edit1 as TiAnalogOutput).Value:=K;
    (Edit2 as TiAnalogOutput).Value:=B;
  end
end;

procedure TSensor.GetFromEdit(Edit1,Edit2:TControl);
begin
  if Edit1.ClassName='TEdit' then
  begin
    K:=StrToFloat((Edit1 as TEdit).Text);
    B:=StrToFloat((Edit2 as TEdit).Text);
  end
  else if Edit1.ClassName='TiEdit' then
  begin
    K:=StrToFloat((Edit1 as TiEdit).Value);
    B:=StrToFloat((Edit2 as TiEdit).Value);
  end
  else if Edit1.ClassName='TiAnalogOutput' then
  begin
    K:=(Edit1 as TiAnalogOutput).Value;
    B:=(Edit2 as TiAnalogOutput).Value;
  end
end;

procedure TSensor.LoadFromFile(filestream:TFileStream);
begin
  filestream.Read(K,sizeof(single));
  filestream.Read(B,sizeof(single));
end; 

procedure TSensor.Sample;
var i:integer;
begin
  for i:=0 to BufCount-2 do DataBuf[i]:=DataBuf[i+1];
  DataBuf[BufCount-1]:=MC1.Sample(Channel)
end;
}

procedure TSensor.Sample(Value:Single);
var i:integer;
begin
  for i:=0 to BufCount-2 do DataBuf[i]:=DataBuf[i+1];
  DataBuf[BufCount-1]:=Value;
end;

function TSensor.GetData(Kind:string):single;
var i:integer;
begin
  Result:=0;
  for i:=0 to BufCount-1 do result:=result+DataBuf[i];
  Voltage:=result/BufCount;
  if Kind ='角度' then  Value:=((Voltage-B)*K)-off;
  if Kind ='转矩' then  Value:=-(Voltage-B)*K;
  Result:=Value;
end;

Constructor TDataFilter.Create(count:integer);
begin
  FilterCount:=count;
  Index:=0;
end;

function TDataFilter.GetData(v:single):single;
var i:integer;
begin
  if Index>=FilterCount then
  begin
    for i:=0 to FilterCount-2 do Buf[i]:=Buf[i+1];
    Buf[FilterCount-1]:=v;
  end
  else
  begin
    Buf[Index]:=v;
    Inc(Index);
  end;

  Result:=0;
  for i:=0 to Index-1 do Result:=Result+Buf[i];
  Result:=Result/Index;
  Value:=Result;
end;

procedure TDataFilter.Clear;
begin
  Index:=0;
end;

procedure SaveFile(ch:Integer);
var FName,Str:String;
    F:TextFile;
    i:Integer;
begin
  if DataBufCount[ch]<10 then Exit;

  FName:=ExtractFilePath(Application.ExeName)+'Data';
  CreateDir(FName);
  FName:=FName+'\CH'+IntToStr(ch+1);
  CreateDir(FName);

  Str:=DateTimeToStr(Now);
  Str:=StringReplace(Str,':','.',[rfReplaceAll]);
  Str:=StringReplace(Str,'/','-',[rfReplaceAll]);
  FName:=FName+'\'+Str+'.Txt';

  AssignFile(F,FName);
  Rewrite(F);
  Str:='时间   最大扭矩   最小扭矩   最大转角   最小转角    当前次数';
  WriteLn(F,Str);
  for i:=0 to DataBufCount[ch]-1 do
  begin
    Str:=Format('%.4f    %.4f    %.4f    %.4f    %.4f    %.4f',[DataBuf[ch,0,i],DataBuf[ch,1,i],DataBuf[ch,2,i],DataBuf[ch,3,i],DataBuf[ch,4,i],DataBuf[ch,5,i]]);
    WriteLn(F,Str);
  end;
  CloseFile(F);
  DataBufCount[ch]:=0;
end;

procedure SaveAllDataFile(ch:Integer);
var FName,Str:String;
    F:TextFile;
    i:Integer;
begin
  if AllDataBufCount[ch]<10 then Exit;

  FName:=ExtractFilePath(Application.ExeName)+'Data';
  CreateDir(FName);
  FName:=FName+'\CH'+IntToStr(ch+1)+'所有数据';
  CreateDir(FName);

  Str:=DateTimeToStr(Now);
  Str:=StringReplace(Str,':','.',[rfReplaceAll]);
  Str:=StringReplace(Str,'/','-',[rfReplaceAll]);
  FName:=FName+'\'+Str+'.Txt';

  AssignFile(F,FName);
  Rewrite(F);
  Str:='时间    当前扭矩    当前角度';
  WriteLn(F,Str);
  for i:=0 to AllDataBufCount[ch]-1 do
  begin
    Str:=Format('%.4f    %.4f    %.4f ',[AllDataBuf[ch,0,i],AllDataBuf[ch,1,i],AllDataBuf[ch,2,i]]);
    WriteLn(F,Str);
  end;
  CloseFile(F);
  AllDataBufCount[ch]:=0;
end;

end.
