unit ThermalHexagon;

interface
uses Hexagon;

type
  TThermalHexagon = class sealed(THexagon)
  type
    TPhysics = class(THexagon.TPhysics)

    end;
  end;
implementation

end.
