addEventHandler('onClientResourceStart', resourceRoot,function()
    local txd = engineLoadTXD('hiz.txd',true)
    engineImportTXD(txd, 2189)
    local dff = engineLoadDFF('hiz.dff', 0)
    engineReplaceModel(dff, 2189)
    local col = engineLoadCOL('hiz.col')
    engineReplaceCOL(col, 2189)
    engineSetModelLODDistance(2189, 9999)
end)
--Shader
local shaderanimarrow = [[
    float2 UVSpeed = float2(-1, 0);
    float2 UVResize = float2(1, 1); 
    float pSpeed = 0.5; 
    float pMinBright = 0.35; 
    texture Tex;
    static const float pi = 3.141592653589793f;
    float gTime : TIME;
    sampler SamplerTex = sampler_state
    {
        Texture = (Tex);
    };
    float getTextureBlink(float pendSpeed, float minBright)
    {
        if (pendSpeed != 0) 
        {
            float pendTime = fmod( gTime * pendSpeed ,1 );
            return 1 - saturate((( cos( pendTime * 2 * pi) + 1) / 2) * (1 - minBright ));
        } 
        else 
        {
            return 1;
        }
    }
    float4 PSFunction(float4 TexCoord : TEXCOORD0, float4 Position : POSITION, float4 Diffuse : COLOR0) : COLOR0
    {
        float posU = fmod( gTime * UVSpeed.x ,1 );
        float posV = fmod( gTime * UVSpeed.y ,1 );
        float4 Tex = tex2D(SamplerTex, float2( TexCoord.x * UVResize.x + posU, TexCoord.y * UVResize.y + posV ));
        Tex.a *= getTextureBlink( pSpeed, pMinBright );
        Tex.a *= Diffuse.a;
        return saturate(Tex);
    }
    technique tec0
    {
        pass p0
        {
        AlphaRef = 1;
        AlphaBlendEnable = TRUE;
        PixelShader = compile ps_2_0 PSFunction();
        }
    }
]]
--
local shader = nil 
--
function startArrowAnim()
    shader = dxCreateShader(shaderanimarrow)
    texture = dxCreateTexture("arrow.png")
    dxSetShaderValue(shader, "Tex", texture)
	dxSetShaderValue(shader, "UVSpeed",  {-2.5,0})
	dxSetShaderValue(shader, "UVResize", {1,1})
	dxSetShaderValue(shader, "pSpeed", 0.7)
	--dxSetShaderValue(shader, "pMinBright", 0.8)
	engineApplyShaderToWorldTexture(shader,"speedup")
end
--
local speedmarkers = {}
local speedshape = {}
--speedmarkers
function createSpeedMarker(x,y,z,alan)
    object = createObject(2189,x,y,z)
    cub = createColCuboid(x-5.75,y-1.56,z,11.5,3.2,3)
    speedshape[cub] = true
    speedmarkers[object] = {alan = cub,obje = object,pos = {x,y,z}}
end
--
function destorySpeedMarker(element)
    if speedmarkers[element] then 
        if isElement(speedmarkers[element].obje) then 
            destroyElement(speedmarkers[element].obje)
        end
        if isElement(speedmarkers[element].alan) then 
            destroyElement(speedmarkers[element].alan)
        end
        speedshape[speedmarkers[element].alan] = nil
        speedmarkers[object] = nil
    end
end
--
a = createSpeedMarker(4030.5, -2014.40, 0.10) -- Creates a speedup marker at the specified coordinates (Location A)
b = createSpeedMarker(1563.58521, -1731.10974, 12.4) -- Creates another speedup marker at different coordinates (Location B)

local mapler = {
    ["Stuf 10"] = {
        [411] = 1.5, -- Setting speed to 0.2 makes it slow, -1 makes it push backward, and 1 makes it fast
    }
}
--
addEventHandler("onClientColShapeHit",root,function(hit)
   if getElementType(hit) == "vehicle" and speedshape[source] == true then 
      local vehspeedx, vehspeedy, vehspeedz = getElementVelocity(hit)
      if mapler["Stuf 10"][getElementModel(hit)]  then 
        hiz = mapler["Stuf 10"][getElementModel(hit)]
      else 
        hiz = 1.5
      end
	  setElementVelocity(hit,vehspeedx*hiz,vehspeedy*hiz,vehspeedz*hiz)
      exports["hareketblur"]:shaderdurumblur(true)
   end
end)
addEventHandler("onClientColShapeLeave",root,function(hit)
    if getElementType(hit) == "vehicle" and speedshape[source] == true then 
       setTimer(function()
        exports["hareketblur"]:shaderdurumblur(false)
       end,700,1)       
    end
end)
--
setDevelopmentMode(true)
--
startArrowAnim()
--