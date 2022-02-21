unit Hexagon;

interface

uses
  System.SysUtils,
  Math;

type
  THexagon = class abstract
  type
    TAxis = (X, Y, Z);
    TBorderNames = (S1, S2, S3, S4, S5, S6);
    TA3THexagon = array of array of array of THexagon;
    TAA3THexagon = array of TA3THexagon;
    TAByte = array of Byte;
    TADouble = array of Double;
    TA2Double = array of array of Double;
    TAA2Double = array of TA2Double;
    TAAA2Double = array of TAA2Double;
    TA3Double = array of array of array of Double;
  protected type
    TPhysics = class abstract
    private
      FVx: Double;
      FVy: Double;
      FVz: Double;
    protected
      constructor Create;
      procedure SetVx(const AVx: Double);
      procedure SetVy(const AVy: Double);
      procedure SetVz(const AVz: Double);
    public
      property Vx: Double read FVx write SetVx;
      property Vy: Double read FVy write SetVy;
      property Vz: Double read FVz write SetVz;
    end;

    TGeometry = class sealed
    private
      FHexagon: THexagon;
      FLx: Double;
      FLy: Double;
      FLz: Double;
      constructor Create(const AHexagon: THexagon);
      procedure SetLx(const ALx: Double);
      procedure SetLy(const ALy: Double);
      procedure SetLz(const ALz: Double);
      property Lx: Double read FLx write SetLx;
      property Ly: Double read FLy write SetLy;
      property Lz: Double read FLz write SetLz;
    end;

    TDiscretization = class
    protected
      FHexagon: THexagon;
      FNLx: SmallInt;
      FNLy: SmallInt;
      FNLz: SmallInt;
      FdTau: Double;
      FDx: Double;
      FDy: Double;
      FDz: Double;
      FSqrDx: Double;
      FSqrDy: Double;
      FSqrDz: Double;
      constructor Create(const AHexagon: THexagon);
      procedure SetNLx(const ANLx: SmallInt);
      procedure SetNLy(const ANLy: SmallInt);
      procedure SetNLz(const ANLz: SmallInt);
      procedure SetdTau(const AdTau: Double);
    public
      property NLx: SmallInt read FNLx write SetNLx;
      property NLy: SmallInt read FNLy write SetNLy;
      property NLz: SmallInt read FNLz write SetNLz;
      property dTau: Double read FdTau write SetdTau;
      property Dx: Double read FDx;
      property Dy: Double read FDy;
      property Dz: Double read FDz;
      property SqrDx: Double read FSqrDx;
      property SqrDy: Double read FSqrDy;
      property SqrDz: Double read FSqrDz;
    end;

    TPosition = class sealed
    private
      FX: SmallInt;
      FY: SmallInt;
      FZ: SmallInt;
      FStorageNumber: SmallInt;
      FStorage: TAA3THexagon;
      constructor Create;
      procedure SetX(const AX: SmallInt);
      procedure SetY(const AY: SmallInt);
      procedure SetZ(const AZ: SmallInt);
      procedure SetStorageNumber(const AStorageNumber: SmallInt);
      procedure SetStorage(const AStorage: TAA3THexagon);
    public
      property X: SmallInt read FX write SetX;
      property Y: SmallInt read FY write SetY;
      property Z: SmallInt read FZ write SetZ;
      property StorageNumber: SmallInt read FStorageNumber write SetStorageNumber;
      property Storage: TAA3THexagon write SetStorage;
    end;

    TVariable = class
    private
      FAxis: TAxis;
      FStart: Double;
      FStop: Double;
      FStep: Double;
      constructor Create;
      procedure SetAxis(const AAxis: TAxis);
      procedure SetStart(const AStart: Double);
      procedure SetStep(const AStep: Double);
      procedure SetStop(const AStop: Double);
      property Axis: TAxis read FAxis write SetAxis;
      property Start: Double read FStart write SetStart;
      property Stop: Double read FStop write SetStop;
      property Step: Double read FStep write SetStep;
    end;

    TConditions = class abstract
    protected type
      TInitialCondition = class
      private
        FHexagon: THexagon;
        FType: Byte;
        FConstant: Double;
        FVariable: TVariable;
        constructor Create(AHexagon: THexagon);
        procedure SetType(const AType: Byte);
        procedure SetConstant(const AConstant: Double);
        procedure Execute;

      public
        property TType: Byte read FType write SetType;
        property Constant: Double read FConstant write SetConstant;
        property Variable: TVariable read FVariable;
      end;

      TBoundaryCondition = class abstract
      private type
        TATVariable = array of TVariable;
      private
        FHexagon: THexagon;
        FType: TAByte;
        FConstant: TADouble;
        FVariable: TATVariable;
        FBorders: TAA2Double;
        FBufferZones: TAAA2Double;
        function GetType(const AN: Byte): Byte;
        function GetConstant(const AN: Byte): Double;
        function GetVariable(const AN: Byte): TVariable;
        procedure SetType(const AN, AType: Byte);
        procedure SetConstant(const AN: Byte; const AConstant: Double);
        procedure Averaging;
      protected
        constructor Create(AHexagon: THexagon);
        procedure Execute; virtual;
      public
        property TType[const N: Byte]: Byte read GetType write SetType;
        property Constant[const N: Byte]: Double read GetConstant write SetConstant;
        property Variable[const N: Byte]: TVariable read GetVariable;
      end;
    private
      FHexagon: THexagon;
    protected
      FInitial: TInitialCondition;
      FBoundary: TBoundaryCondition;
      constructor Create(const AHexagon: THexagon);
    public
      property Initial: TInitialCondition read FInitial;
      property Boundary: TBoundaryCondition read FBoundary;
    end;

    TData = class abstract
    private
      FHexagon: THexagon;
    protected
      FdF: TA3Double;
      FF: TA3Double;
      constructor Create(AHexagon: THexagon);
    end;

  protected
    FPhysics: TPhysics;
    FGeometry: TGeometry;
    FDiscretization: TDiscretization;
    FPosition: TPosition;
    FConditions: TConditions;
    FData: TData;
    constructor Create;
    procedure RecalcParams(const APhysics, AGeometry, ADiscretization, AConditions, AData: Boolean); overload; virtual;
    procedure RecalcParams(const AN: TBorderNames; const ANLn, ANLm: SmallInt); overload;
  public
    procedure Process; virtual;
    property Geometry: TGeometry read FGeometry;
    property Discretization: TDiscretization read FDiscretization;
    property Position: TPosition read FPosition;

  end;

implementation

{ THexagon }

constructor THexagon.Create;
begin
  FGeometry := TGeometry.Create(Self);
  FDiscretization := TDiscretization.Create(Self);
  FPosition := TPosition.Create;
end;

procedure THexagon.RecalcParams(const APhysics, AGeometry, ADiscretization, AConditions, AData: Boolean);
var
  N: TBorderNames;
  BN: ^Byte;
  F: ^TA3Double;
  dF: ^TA3Double;
  Lx: Double;
  Ly: Double;
  Lz: Double;
  NLx: SmallInt;
  NLy: SmallInt;
  NLz: SmallInt;
  Dx: ^Double;
  Dy: ^Double;
  Dz: ^Double;
  SqrDx: ^Double;
  SqrDy: ^Double;
  SqrDz: ^Double;
begin
  if (FPhysics <> nil) and (FGeometry <> nil) and (FDiscretization <> nil) and (FPosition <> nil) and (FConditions <> nil) and (FData <> nil) then
  begin
    BN := @Byte(N);
    Lx := FGeometry.FLx;
    Ly := FGeometry.FLy;
    Lz := FGeometry.FLz;
    NLx := FDiscretization.FNLx;
    NLy := FDiscretization.FNLy;
    NLz := FDiscretization.FNLz;
    Dx := @FDiscretization.FDx;
    Dy := @FDiscretization.FDy;
    Dz := @FDiscretization.FDz;
    SqrDx := @FDiscretization.FSqrDx;
    SqrDy := @FDiscretization.FSqrDy;
    SqrDz := @FDiscretization.FSqrDz;
    F := @FData.FF;
    dF := @FData.FdF;
    if AGeometry or ADiscretization then
    begin
      if NLx > 0 then
        Dx^ := Lx / NLx;
      if NLy > 0 then
        Dy^ := Ly / NLy;
      if NLz > 0 then
        Dz^ := Lz / NLz;
      SqrDx^ := Dx^ * Dx^;
      SqrDy^ := Dy^ * Dy^;
      SqrDz^ := Dz^ * Dz^;
    end;
    if AData then
    begin
      SetLength(dF^, NLx + 1, NLy + 1, NLz + 1);
      SetLength(F^, NLx + 1, NLy + 1, NLz + 1);
    end;
    if AConditions then
    begin
      for N := S1 to S6 do
        case FConditions.FBoundary.FType[BN^] of
          0, 2:
            case N of
              S1, S6:
                begin
                  SetLength(FConditions.FBoundary.FBorders[BN^], NLx + 1, NLy + 1);
                  RecalcParams(N, NLx, NLy);
                end;
              S2, S3:
                begin
                  SetLength(FConditions.FBoundary.FBorders[BN^], NLy + 1, NLz + 1);
                  RecalcParams(N, NLy, NLz);
                end;
              S4, S5:
                begin
                  SetLength(FConditions.FBoundary.FBorders[BN^], NLx + 1, NLz + 1);
                  RecalcParams(N, NLx, NLz);
                end;
            else
              SetLength(FConditions.FBoundary.FBorders[BN^], 0, 0);
            end;
        end;
    end;
  end;
end;

procedure THexagon.RecalcParams(const AN: TBorderNames; const ANLn, ANLm: SmallInt);
var
  N: SmallInt;
  M: SmallInt;
  L: SmallInt;
  Steps: SmallInt;
  Value: Double;
  BAN: Byte;
begin
  BAN := Byte(AN);
  case FConditions.Boundary.FType[BAN] of
    0:
      for N := 0 to ANLn do
        for M := 0 to ANLm do
          FConditions.Boundary.FBorders[BAN][N, M] := FConditions.Boundary.FConstant[BAN];
    2:
      begin
        Steps := Abs(Floor((FConditions.Boundary.FVariable[BAN].FStart - FConditions.Boundary.FVariable[BAN].FStop) / FConditions.Boundary.FVariable[BAN].FStep));
        for N := 0 to ANLn do
          for M := 0 to ANLm do
          begin
            case FConditions.Boundary.FVariable[BAN].FAxis of
              X:
                if AN in [S1, S4, S5, S6] then
                  L := N
                else
                  L := -1;
              Y:
                if AN in [S1, S2, S3, S6] then
                  L := M
                else
                  L := -1;
              Z:
                if AN in [S2, S3, S4, S5] then
                  L := M
                else
                  L := -1;
            end;
            if L >= Steps then
              Value := FConditions.Boundary.FVariable[BAN].FStop
            else
              Value := FConditions.Boundary.FVariable[BAN].Start + FConditions.Boundary.FVariable[BAN].Step * L;
            if L = -1 then
              Value := FConditions.Boundary.FVariable[BAN].Start;
            FConditions.Boundary.FBorders[BAN][N, M] := Value;
          end;
      end;
  end;
end;

procedure THexagon.Process;
var
  I: SmallInt;
  J: SmallInt;
  K: SmallInt;
begin
  for I := 1 to FDiscretization.FNLx - 1 do
    for J := 1 to FDiscretization.FNLy - 1 do
      for K := 1 to FDiscretization.FNLz - 1 do
        FData.FF[I, J, K] := FData.FF[I, J, K] + FData.FdF[I, J, K];
  FConditions.FBoundary.Execute;
end;

{ THexagon.TPhysics }

constructor THexagon.TPhysics.Create;
begin
  Vx := 0;
  Vy := 0;
  Vz := 0;
end;

procedure THexagon.TPhysics.SetVx(const AVx: Double);
begin
  FVx := AVx;
end;

procedure THexagon.TPhysics.SetVy(const AVy: Double);
begin
  FVy := AVy;
end;

procedure THexagon.TPhysics.SetVz(const AVz: Double);
begin
  FVz := AVz;
end;

{ THexagon.TGeometry }

constructor THexagon.TGeometry.Create(const AHexagon: THexagon);
begin
  FHexagon := AHexagon;
  Lx := 1;
  Ly := 1;
  Lz := 1;
end;

procedure THexagon.TGeometry.SetLx(const ALx: Double);
var
  PrevLx: Double;
begin
  if ALx <= 0 then
    raise EArgumentOutOfRangeException.Create('Lx, out of range (Lx > 0)');
  PrevLx := FLx;
  FLx := ALx;
  if (PrevLx <> ALx) then
    FHexagon.RecalcParams(False, True, False, False, False);
end;

procedure THexagon.TGeometry.SetLy(const ALy: Double);
var
  PrevLy: Double;
begin
  if ALy <= 0 then
    raise EArgumentOutOfRangeException.Create('Ly, out of range (Ly > 0)');
  PrevLy := FLy;
  FLy := ALy;
  if (PrevLy <> ALy) then
    FHexagon.RecalcParams(False, True, False, False, False);
end;

procedure THexagon.TGeometry.SetLz(const ALz: Double);
var
  PrevLz: Double;
begin
  if ALz <= 0 then
    raise EArgumentOutOfRangeException.Create('Lz, out of range (Lz > 0)');
  PrevLz := FLz;
  FLz := ALz;
  if (PrevLz <> ALz) then
    FHexagon.RecalcParams(False, True, False, False, False);
end;

{ THexagon.TDiscretization }

constructor THexagon.TDiscretization.Create(const AHexagon: THexagon);
begin
  FHexagon := AHexagon;
  NLx := 10;
  NLy := 10;
  NLz := 10;
end;

procedure THexagon.TDiscretization.SetNLx(const ANLx: SmallInt);
var
  PrevNLx: SmallInt;
begin
  if ANLx < 3 then
    raise EArgumentOutOfRangeException.Create('NLx, out of range (NLx >= 3)');
  PrevNLx := FNLx;
  FNLx := ANLx;
  if PrevNLx <> FNLx then
    FHexagon.RecalcParams(False, False, True, False, False);
end;

procedure THexagon.TDiscretization.SetNLy(const ANLy: SmallInt);
var
  PrevNLy: SmallInt;
begin
  if ANLy < 3 then
    raise EArgumentOutOfRangeException.Create('NLy, out of range (NLy >= 3)');
  PrevNLy := FNLy;
  FNLy := ANLy;
  if PrevNLy <> FNLy then
    FHexagon.RecalcParams(False, False, True, False, True);
end;

procedure THexagon.TDiscretization.SetNLz(const ANLz: SmallInt);
var
  PrevNLz: SmallInt;
begin
  if ANLz < 3 then
    raise EArgumentOutOfRangeException.Create('NLz, out of range (NLz >= 3)');
  PrevNLz := FNLz;
  FNLy := ANLz;
  if PrevNLz <> FNLz then
    FHexagon.RecalcParams(False, False, True, False, False);
end;

procedure THexagon.TDiscretization.SetdTau(const AdTau: Double);
begin
  if AdTau <= 0 then
    raise EArgumentOutOfRangeException.Create('dTau, out of range (dTau > 0)');
  FdTau := AdTau;
end;

{ THexagon.TPosition }

constructor THexagon.TPosition.Create;
begin
  X := 0;
  Y := 0;
  Z := 0;
  StorageNumber := 0;
end;

procedure THexagon.TPosition.SetX(const AX: SmallInt);
begin
  if (AX < 0) then
    raise EArgumentOutOfRangeException.Create('X, out of range (X >= 0)');
  FX := AX;
end;

procedure THexagon.TPosition.SetY(const AY: SmallInt);
begin
  if (AY < 0) then
    raise EArgumentOutOfRangeException.Create('Y, out of range (Y >= 0)');
  FY := AY;
end;

procedure THexagon.TPosition.SetZ(const AZ: SmallInt);
begin
  if (AZ < 0) then
    raise EArgumentOutOfRangeException.Create('Z, out of range (Z >= 0)');
  FZ := AZ;
end;

procedure THexagon.TPosition.SetStorageNumber(const AStorageNumber: SmallInt);
begin
  if (AStorageNumber < 0) then
    raise EArgumentOutOfRangeException.Create('StorageNumber, out of range (StorageNumber >= 0)');
  FStorageNumber := AStorageNumber;
end;

procedure THexagon.TPosition.SetStorage(const AStorage: TAA3THexagon);
begin
  if AStorage = nil then
    raise EArgumentNilException.Create('Storage <> nil');
end;

{ THexagon.TVariable }

constructor THexagon.TVariable.Create;
begin
  Axis := X;
  Start := 0;
  Stop := 0;
  Step := 1;
end;

procedure THexagon.TVariable.SetAxis(const AAxis: TAxis);
begin
  FAxis := AAxis;
end;

procedure THexagon.TVariable.SetStart(const AStart: Double);
begin
  FStart := AStart;
end;

procedure THexagon.TVariable.SetStep(const AStep: Double);
begin
  if AStep = 0 then
    raise EArgumentOutOfRangeException.Create('Step, out of range (Step <> 0)');
  FStep := AStep;
end;

procedure THexagon.TVariable.SetStop(const AStop: Double);
begin
  FStop := AStop;
end;

{ THexagon.TConditions }

constructor THexagon.TConditions.Create(const AHexagon: THexagon);
begin
  FHexagon := AHexagon;
  FInitial := TInitialCondition.Create(AHexagon);
end;

{ THexagon.TConditions.TInitialCondition }

constructor THexagon.TConditions.TInitialCondition.Create(AHexagon: THexagon);
begin
  TType := 0;
  Constant := 0;
  FVariable := TVariable.Create;
  Variable.Start := 0;
  Variable.Stop := 0;
  Variable.Step := 1;
end;

procedure THexagon.TConditions.TInitialCondition.SetType(const AType: Byte);
var
  PrevType: Byte;
begin
  if AType > 1 then
    raise EArgumentOutOfRangeException.Create('Type, out of range (Type <= 1)');
  PrevType := FType;
  FType := AType;
  if PrevType <> FType then
    Execute;
end;

procedure THexagon.TConditions.TInitialCondition.SetConstant(const AConstant: Double);
begin
  FConstant := AConstant;
end;

procedure THexagon.TConditions.TInitialCondition.Execute;
begin

end;

{ THexagon.TConditions.TBoundaryCondition }

constructor THexagon.TConditions.TBoundaryCondition.Create(AHexagon: THexagon);
begin
  FHexagon := AHexagon;
  SetLength(FType, 6);
  SetLength(FConstant, 6);
  SetLength(FVariable, 6);
  SetLength(FBorders, 6);
end;

function THexagon.TConditions.TBoundaryCondition.GetType(const AN: Byte): Byte;
begin
  if AN > 5 then
    raise EArgumentOutOfRangeException.Create('N, out of range (N <= 5)');
  Result := FType[AN];
end;

function THexagon.TConditions.TBoundaryCondition.GetConstant(const AN: Byte): Double;
begin
  if AN > 5 then
    raise EArgumentOutOfRangeException.Create('N, out of range (N <= 5)');
  Result := FConstant[AN];
end;

function THexagon.TConditions.TBoundaryCondition.GetVariable(const AN: Byte): TVariable;
begin
  if AN > 5 then
    raise EArgumentOutOfRangeException.Create('N, out of range (N <= 5)');
  Result := FVariable[AN];
end;

procedure THexagon.TConditions.TBoundaryCondition.SetType(const AN, AType: Byte);
var
  PrevType: Byte;
begin
  if AN > 5 then
    raise EArgumentOutOfRangeException.Create('N, out of range (N <= 5)');
  if AType > 5 then
    raise EArgumentOutOfRangeException.Create('TType, out of range (TType <= 5)');
  PrevType := FType[AN];
  FType[AN] := AType;
  if PrevType <> FType[AN] then
    FHexagon.RecalcParams(False, False, False, True, False);
end;

procedure THexagon.TConditions.TBoundaryCondition.SetConstant(const AN: Byte; const AConstant: Double);
var
  PrevConstant: Double;
begin
  if AN > 5 then
    raise EArgumentOutOfRangeException.Create('N, out of range (N <= 5)');
  PrevConstant := FConstant[AN];
  FConstant[AN] := AConstant;
  if PrevConstant <> FConstant[AN] then
    FHexagon.RecalcParams(False, False, False, True, False);
end;

procedure THexagon.TConditions.TBoundaryCondition.Execute;
var
  F: ^TA3Double;
  BN: ^Byte;
  NLx: SmallInt;
  NLy: SmallInt;
  NLz: SmallInt;
  N: TBorderNames;
  I: SmallInt;
  J: SmallInt;
  K: SmallInt;
begin
  F := @FHexagon.FData.FF;
  BN := @Byte(N);
  NLx := FHexagon.FDiscretization.FNLx;
  NLy := FHexagon.FDiscretization.FNLy;
  NLz := FHexagon.FDiscretization.FNLz;
  for N := S1 to S6 do
    if FType[BN^] in [0, 2] then
      case N of
        S1:
          for I := 1 To NLx - 1 Do
            for J := 1 To NLy - 1 Do
              F^[I, J, NLz] := FBorders[BN^][I, J];
        S2:
          for J := 1 to NLy - 1 Do
            for K := 1 To NLz - 1 Do
              F^[0, J, K] := FBorders[BN^][J, K];
        S3:
          for J := 1 To NLy - 1 Do
            for K := 1 To NLz - 1 Do
              F^[NLx, J, K] := FBorders[BN^][J, K];
        S4:
          for I := 1 To NLx - 1 Do
            for K := 1 To NLz - 1 Do
              F^[I, 0, K] := FBorders[BN^][I, K];
        S5:
          for I := 1 To NLx - 1 Do
            for K := 1 To NLz - 1 Do
              F^[I, NLy, K] := FBorders[BN^][I, K];
        S6:
          for I := 1 To NLx - 1 Do
            for J := 1 To NLy - 1 Do
              F^[I, J, 0] := FBorders[BN^][I, J];
      end
    else if FType[BN^] = 1 then
      case N of
        S1:
          for I := 1 To NLx - 1 Do
            for J := 1 To NLy - 1 Do
              F^[I, J, NLz] := F^[I, J, NLz - 1];
        S2:
          for J := 1 To NLy - 1 Do
            for K := 1 To NLz - 1 Do
              F^[0, J, K] := F^[1, J, K];
        S3:
          for J := 1 To NLy - 1 Do
            for K := 1 To NLz - 1 Do
              F^[NLx, J, K] := F^[NLx - 1, J, K];
        S4:
          for I := 1 To NLx - 1 Do
            for K := 1 To NLz - 1 Do
              F^[I, 0, K] := F^[I, 1, K];
        S5:
          for I := 1 To NLx - 1 Do
            for K := 1 To NLz - 1 Do
              F^[I, NLy, K] := F^[I, NLy - 1, K];
        S6:
          for I := 1 To NLx - 1 Do
            for J := 1 To NLy - 1 Do
              F^[I, J, 0] := F^[I, J, 1];
      end;
  Averaging;
end;

procedure THexagon.TConditions.TBoundaryCondition.Averaging;
Var
  I: Integer;
  J: Integer;
  K: Integer;
  F: ^TA3Double;
  NLx: SmallInt;
  NLy: SmallInt;
  NLz: SmallInt;
Begin
  F := @FHexagon.FData.FF;
  NLx := FHexagon.FDiscretization.FNLx;
  NLy := FHexagon.FDiscretization.FNLy;
  NLz := FHexagon.FDiscretization.FNLz;
  For I := 1 to NLx - 1 Do
  Begin
    F^[I, 0, 0] := (F^[I, 1, 0] + F^[I, 0, 1]) / 2;
    F^[I, NLy, 0] := (F^[I, NLy - 1, 0] + F^[I, NLy, 1]) / 2;
    F^[I, 0, NLz] := (F^[I, 1, NLz] + F^[I, 0, NLz - 1]) / 2;
    F^[I, NLy, NLz] := (F^[I, NLy - 1, NLz] + F^[I, NLy, NLz - 1]) / 2;
  End;
  For J := 1 to NLy - 1 Do
  Begin
    F^[0, J, 0] := (F^[1, J, 0] + F^[0, J, 1]) / 2;
    F^[NLx, J, 0] := (F^[NLx - 1, J, 0] + F^[NLx, J, 1]) / 2;
    F^[0, J, NLz] := (F^[1, J, NLz] + F^[0, J, NLz - 1]) / 2;
    F^[NLx, J, NLz] := (F^[NLx - 1, J, NLz] + F^[NLx, J, NLz - 1]) / 2;
  End;
  For K := 1 to NLz - 1 Do
  Begin
    F^[0, 0, K] := (F^[1, 0, K] + F^[0, 1, K]) / 2;
    F^[NLx, 0, K] := (F^[NLx - 1, 0, K] + F^[NLx, 1, K]) / 2;
    F^[0, NLy, K] := (F^[1, NLy, K] + F^[0, NLy - 1, K]) / 2;
    F^[NLx, NLy, K] := (F^[NLx - 1, NLy, K] + F^[NLx, NLy - 1, K]) / 2;
  End;
  F^[0, 0, 0] := (F^[1, 0, 0] + F^[0, 1, 0] + F^[0, 0, 1]) / 3;
  F^[NLx, 0, 0] := (F^[NLx - 1, 0, 0] + F^[NLx, 1, 0] + F^[NLx, 0, 1]) / 3;
  F^[0, NLy, 0] := (F^[1, NLy, 0] + F^[0, NLy - 1, 0] + F^[0, NLy, 1]) / 3;
  F^[0, 0, NLz] := (F^[1, 0, NLz] + F^[0, 1, NLz] + F^[0, 0, NLz - 1]) / 3;
  F^[NLx, NLy, 0] := (F^[NLx - 1, NLy, 0] + F^[NLx, NLy - 1, 0] + F^[NLx, NLy, 1]) / 3;
  F^[NLx, NLy, NLz] := (F^[NLx - 1, NLy, NLz] + F^[NLx, NLy - 1, NLz] + F^[NLx, NLy, NLz - 1]) / 3;
  F^[0, NLy, NLz] := (F^[1, NLy, NLz] + F^[0, NLy - 1, NLz] + F^[0, NLy, NLz - 1]) / 3;
  F^[NLx, 0, NLz] := (F^[NLx - 1, 0, NLz] + F^[NLx, 1, NLz] + F^[NLx, 0, NLz - 1]) / 3;
end;

{ THexagon.TData }

constructor THexagon.TData.Create(AHexagon: THexagon);
begin
  FHexagon := AHexagon;
  FHexagon.RecalcParams(False, False, False, False, True);
end;

end.
