unit HydroHexagon;

interface

uses
  Hexagon, System.SysUtils;

type
  THydroHexagon = class sealed(THexagon)
  private type
  
    TPhysics = class sealed(THexagon.TPhysics)
    private type
      TB = class sealed
      private type
        TADouble = array of Double;
      private
        FS: TADouble;
        constructor Create;
        function GetS(const AN: Byte): Double;
        procedure SetS(const AN: Byte; const AAS: Double);
      public
        property S[const N: Byte]: Double read GetS write SetS;
      end;
    private
      FKx: Double;
      FKy: Double;
      FKz: Double;
      FEta: Double;
      FB: TB;
      constructor Create;
      procedure SetKx(const AKx: Double);
      procedure SetKy(const AKy: Double);
      procedure SetKz(const AKz: Double);
      procedure SetEta(const AEta: Double);
    public
      property Kx: Double read FKx write SetKx;
      property Ky: Double read FKy write SetKy;
      property Kz: Double read FKz write SetKz;
      property Eta: Double read FEta write SetEta;
      property B: TB read FB;
    end;
    
    TConditions = class sealed(THexagon.TConditions)
    private type
      TBoundaryCondition = class sealed(THexagon.TConditions.TBoundaryCondition)
      protected
        constructor Create(AHexagon: THydroHexagon);
        procedure Execute; override; final;
      end;
    protected
      FBoundary: TBoundaryCondition;
      constructor Create(AHexagon: THydroHexagon);
    end;

    TData = class sealed(THexagon.TData)
    public
      function GetPressure(I, J, K: Integer): Double;
    end;
  protected
    FPhysics: TPhysics;
    FData: TData;
    function GetConditions: TConditions;
//    procedure RecalcParams(const APhysics, AGeometry, ADiscretization, AConditions, AData: Boolean); override;
  public
    constructor Create;
    property Physics: TPhysics read FPhysics;
    property Conditions: TConditions read GetConditions;
    property Data: TData read FData;
    procedure Process; override;
  end;

implementation

{ THydroHexagon }

constructor THydroHexagon.Create;
begin
  inherited Create;
  FPhysics := TPhysics.Create;
  FConditions := TConditions.Create(Self);
  FData := TData.Create(Self);
  RecalcParams(True, True, True, True, True);
end;

function THydroHexagon.GetConditions: TConditions;
begin
  Result := TConditions(FConditions);
end;

procedure THydroHexagon.Process;
var
  I: SmallInt;
  J: SmallInt;
  K: SmallInt;
  F: ^TA3Double;
  dF: ^TA3Double;
  Vx: Double;
  Vy: Double;
  Vz: Double;
  Eta: Double;
  NLx: SmallInt;
  NLy: SmallInt;
  NLz: SmallInt;
  dTau: Double;
  Dx: Double;
  Dy: Double;
  Dz: Double;
  SqrDx: Double;
  SqrDy: Double;
  SqrDz: Double;
begin
  F := @FData.FF;
  dF := @FData.FdF;
  Vx := FPhysics.Vx;
  Vy := FPhysics.Vy;
  Vz := FPhysics.Vz;
  Eta := FPhysics.FEta;
  NLx := FDiscretization.NLx;
  NLy := FDiscretization.NLy;
  NLz := FDiscretization.NLz;
  dTau := FDiscretization.dTau;
  Dx := Discretization.Dx;
  Dy := Discretization.Dy;
  Dz := Discretization.Dz;
  SqrDx := Discretization.SqrDx;
  SqrDy := Discretization.SqrDy;
  SqrDz := Discretization.SqrDz;
  //FConditions.Boundary.Execute;
  for I := 1 to NLx - 1 do
    for J := 1 to NLy - 1 do
      for K := 1 to NLz - 1 do
        dF^[I, J, K] := dTau * (1 / Eta * ((F^[I - 1, J, K] - 2 * F^[I, J, K] + F^[I + 1, J, K]) / SqrDx + (F^[I, J - 1, K] - 2 * F^[I, J, K] + F^[I, J + 1, K]) / SqrDy + (F^[I - 1, J, K] - 2 * F^[I, J, K] + F^[I + 1, J, K]) / SqrDz) - Vx * (F^[I, J, K] - F^[I - 1, J, K]) / Dx - Vy * (F^[I, J, K] - F^[I, J - 1, K]) / Dy - Vz * (F^[I, J, K] - F^[I, J + 1, K]) / Dz);
  inherited Process;
end;

//procedure THydroHexagon.RecalcParams(const APhysics, AGeometry, ADiscretization, AConditions, AData: Boolean);
//begin
//  inherited RecalcParams(APhysics, AGeometry, ADiscretization, AConditions, AData);
//  
//
//end;

{ THydroHexagon.TPhysics }

constructor THydroHexagon.TPhysics.Create;
var
  N: Byte;
begin
  inherited Create;
  Kx := 1;
  Ky := 1;
  Kz := 1;
  Eta := 1;
  FB := TB.Create;
  for N := 0 to 5 do
    B.S[N] := 0.001;
end;

procedure THydroHexagon.TPhysics.SetKx(const AKx: Double);
begin
  if AKx <= 0 then
    raise EArgumentOutOfRangeException.Create('Kx, out of range (Kx > 0)');
  FKx := AKx;
end;

procedure THydroHexagon.TPhysics.SetKy(const AKy: Double);
begin
  if AKy <= 0 then
    raise EArgumentOutOfRangeException.Create('Ky, out of range (Ky > 0)');
  FKy := AKy;
end;

procedure THydroHexagon.TPhysics.SetKz(const AKz: Double);
begin
  if AKz <= 0 then
    raise EArgumentOutOfRangeException.Create('Kz, out of range (Kz > 0)');
  FKz := AKz;
end;

procedure THydroHexagon.TPhysics.SetEta(const AEta: Double);
begin
  if AEta <= 0 then
    raise EArgumentOutOfRangeException.Create('Eta, out of range (Eta > 0)');
  FEta := AEta;
end;

{ THydroHexagon.TPhysics.TB }

constructor THydroHexagon.TPhysics.TB.Create;
var
  N: Byte;
begin
  SetLength(FS, 6);
  for N := 0 to 5 do
    S[N] := 0.0001;
end;

function THydroHexagon.TPhysics.TB.GetS(const AN: Byte): Double;
begin
  Result := FS[AN];
end;

procedure THydroHexagon.TPhysics.TB.SetS(const AN: Byte; const AAS: Double);
begin
  if AN > 5 then
    raise EArgumentOutOfRangeException.Create('N, out of range (N <= 5)');
  if AAS <= 0 then
    raise EArgumentOutOfRangeException.Create('S, out of range (S > 0)');
  FS[AN] := AAS;
end;

{ THydroHexagon.TConditions.TBoundaryCondition }

constructor THydroHexagon.TConditions.TBoundaryCondition.Create(AHexagon: THydroHexagon);
begin
  inherited Create;
end;

procedure THydroHexagon.TConditions.TBoundaryCondition.Execute;
begin
  inherited Execute;

end;

{ THydroHexagon.TData }

//constructor THydroHexagon.TData.Create(AHexagon: THydroHexagon);
//begin
//  inherited Create(AHexagon);
//end;

function THydroHexagon.TData.GetPressure(I, J, K: Integer): Double;
begin
  Result := FF[I, J, K];
end;

{ THydroHexagon.TConditions }

constructor THydroHexagon.TConditions.Create(AHexagon: THydroHexagon);
begin
  inherited Create(AHexagon);
end;

end.
