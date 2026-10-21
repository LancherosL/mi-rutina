-- Base inicial de alimentos (el perfil vive sólo en Supabase).
-- Valores por 100 g. Fuente: USDA SR Legacy (número FDC en `fuente`) o receta calculada
-- ingrediente por ingrediente con esos mismos valores. null = sin dato (no se inventa).

insert into public.nutri_alimentos
  (nombre, norm, categoria, porciones, kcal, proteina, carbo, grasa, fibra, calcio_mg, vitd_ui, lactosa, cafeina, fuente)
values
-- Huevos y proteína
('Huevo','huevo','proteina','[{"u":"unidad","g":50}]',143,12.6,0.7,9.5,0,56,82,false,false,'USDA 01123'),
('Clara de huevo','clara de huevo','proteina','[{"u":"unidad","g":33}]',52,10.9,0.7,0.2,0,7,0,false,false,'USDA 01124'),
('Huevos pericos','huevos pericos','plato','[{"u":"porción (2 huevos)","g":140}]',143,9.4,2.7,10.4,0.5,45,null,false,false,'receta calculada: 2 huevos, tomate, cebolla, 5 g aceite'),
('Pechuga de pollo cocida','pechuga de pollo cocida','proteina','[{"u":"filete","g":150},{"u":"presa","g":120}]',165,31.0,0,3.6,0,15,null,false,false,'USDA 05064'),
('Muslo de pollo cocido sin piel','muslo de pollo cocido sin piel','proteina','[{"u":"presa","g":100}]',209,25.9,0,10.9,0,12,null,false,false,'USDA 05096'),
('Carne molida de res 85% cocida','carne molida de res cocida','proteina','[{"u":"porción","g":100},{"u":"cda","g":15}]',250,25.9,0,15.4,0,18,null,false,false,'USDA 23572'),
('Lomo de cerdo cocido','lomo de cerdo cocido','proteina','[{"u":"porción","g":100}]',143,26.2,0,3.5,0,6,null,false,false,'USDA 10060'),
('Atún en agua escurrido','atun en agua','proteina','[{"u":"lata escurrida","g":120},{"u":"cda","g":15}]',116,25.5,0,0.8,0,11,null,false,false,'USDA 15121'),
('Salmón cocido','salmon cocido','proteina','[{"u":"filete","g":120}]',206,22.1,0,12.4,0,15,526,false,false,'USDA 15237 (cultivado)'),
('Tilapia cocida','tilapia cocida','proteina','[{"u":"filete","g":120}]',128,26.2,0,2.7,0,14,null,false,false,'USDA 15262'),
('Sardinas en aceite escurridas','sardinas en aceite','proteina','[{"u":"lata escurrida","g":92},{"u":"unidad","g":12}]',208,24.6,0,11.5,0,382,193,false,false,'USDA 15088'),
('Tofu firme (con calcio)','tofu firme','proteina','[{"u":"porción","g":100},{"u":"taza","g":126}]',144,17.3,2.8,8.7,2.3,683,null,false,false,'USDA 16427 (calcio varía por marca: escanear)'),
-- Granos y legumbres
('Arroz blanco cocido','arroz blanco cocido','grano','[{"u":"taza","g":158},{"u":"cucharón","g":100}]',130,2.7,28.2,0.3,0.4,10,0,false,false,'USDA 20045'),
('Arroz integral cocido','arroz integral cocido','grano','[{"u":"taza","g":195}]',123,2.7,25.6,1.0,1.6,3,0,false,false,'USDA 20037'),
('Frijoles rojos cocidos','frijoles','legumbre','[{"u":"taza","g":177},{"u":"cucharón","g":150}]',127,8.7,22.8,0.5,6.4,28,0,false,false,'USDA 16033'),
('Lentejas cocidas','lentejas','legumbre','[{"u":"taza","g":198},{"u":"cucharón","g":150}]',116,9.0,20.1,0.4,7.9,19,0,false,false,'USDA 16070'),
('Garbanzos cocidos','garbanzos','legumbre','[{"u":"taza","g":164}]',164,8.9,27.4,2.6,7.6,49,0,false,false,'USDA 16057'),
('Avena en hojuelas (cruda)','avena','grano','[{"u":"taza","g":80},{"u":"cda","g":5}]',379,13.2,67.7,6.5,10.1,52,0,false,false,'USDA 08120'),
('Pasta cocida','pasta cocida','grano','[{"u":"taza","g":140}]',158,5.8,30.9,0.9,1.8,7,0,false,false,'USDA 20121'),
('Quinoa cocida','quinoa cocida','grano','[{"u":"taza","g":185}]',120,4.4,21.3,1.9,2.8,17,0,false,false,'USDA 20137'),
('Pan tajado blanco','pan tajado blanco','grano','[{"u":"tajada","g":25}]',266,7.6,49.2,3.3,2.7,null,null,false,false,'USDA 18069 (calcio varía por marca)'),
('Pan integral','pan integral','grano','[{"u":"tajada","g":32}]',252,12.4,42.7,3.5,6.0,null,null,false,false,'USDA 18075'),
-- Arepas, plátano, tubérculos
('Arepa blanca','arepa','arepa','[{"u":"mediana","g":80},{"u":"pequeña","g":50}]',185,3.7,40.0,0.8,2.1,4,0,false,false,'receta calculada: harina de maíz precocida + agua, sin grasa'),
('Arepa con queso','arepa con queso','arepa','[{"u":"mediana","g":100}]',210,7.0,32.5,5.4,1.7,141,null,true,false,'receta calculada: 80 g arepa + 20 g queso fresco'),
('Plátano maduro cocido/asado','platano maduro cocido','platano','[{"u":"unidad","g":180},{"u":"½ unidad","g":90}]',116,0.8,31.2,0.2,2.3,2,0,false,false,'USDA 09278'),
('Plátano maduro frito (tajadas)','platano maduro frito','platano','[{"u":"tajada","g":30}]',236,1.5,40.2,8.2,2.3,3,0,false,false,'USDA 09401'),
('Patacón','patacon','platano','[{"u":"unidad","g":35}]',309,1.5,50.2,11.8,3.5,5,0,false,false,'USDA 09393 (tostones)'),
('Papa cocida','papa cocida','tuberculo','[{"u":"mediana","g":150},{"u":"pequeña","g":80}]',86,1.7,20.0,0.1,1.8,8,0,false,false,'USDA 11367'),
('Papa criolla cocida','papa criolla','tuberculo','[{"u":"unidad","g":25}]',87,1.9,20.1,0.1,1.8,5,0,false,false,'USDA 11365 (papa con piel; criolla sin dato propio)'),
('Yuca (peso crudo)','yuca','tuberculo','[{"u":"trozo","g":100}]',160,1.4,38.1,0.3,1.8,16,0,false,false,'USDA 11134 cruda: pesar antes de cocinar'),
('Mazorca / maíz tierno cocido','mazorca','grano','[{"u":"taza de granos","g":145},{"u":"mazorca","g":100}]',96,3.4,21.0,1.5,2.4,3,0,false,false,'USDA 11168'),
-- Platos colombianos
('Ajiaco (sin crema)','ajiaco','plato','[{"u":"plato","g":450}]',63,5.4,9.2,0.7,1.1,7,null,false,false,'receta calculada: pollo, 3 papas, mazorca, cebolla, guascas. Crema aparte'),
('Sudado de pollo con papa','sudado de pollo','plato','[{"u":"plato","g":350}]',88,9.2,6.9,2.6,1.0,10,null,false,false,'receta calculada: muslo, papa, tomate, cebolla, 15 g aceite'),
-- Frutas
('Aguacate','aguacate','fruta','[{"u":"unidad","g":136},{"u":"¼","g":34}]',160,2.0,8.5,14.7,6.7,12,0,false,false,'USDA 09037'),
('Banano','banano','fruta','[{"u":"unidad","g":118}]',89,1.1,22.8,0.3,2.6,5,0,false,false,'USDA 09040'),
('Manzana','manzana','fruta','[{"u":"unidad","g":182}]',52,0.3,13.8,0.2,2.4,6,0,false,false,'USDA 09003'),
('Papaya','papaya','fruta','[{"u":"taza","g":145}]',43,0.5,10.8,0.3,1.7,20,0,false,false,'USDA 09226'),
('Mango','mango','fruta','[{"u":"taza","g":165}]',60,0.8,15.0,0.4,1.6,11,0,false,false,'USDA 09176'),
('Fresas','fresas','fruta','[{"u":"taza","g":152}]',32,0.7,7.7,0.3,2.0,16,0,false,false,'USDA 09316'),
('Arándanos','arandanos','fruta','[{"u":"taza","g":148}]',57,0.7,14.5,0.3,2.4,6,0,false,false,'USDA 09050'),
('Naranja','naranja','fruta','[{"u":"unidad","g":131}]',47,0.9,11.8,0.1,2.4,40,0,false,false,'USDA 09200'),
('Uvas','uvas','fruta','[{"u":"taza","g":151},{"u":"10 uvas","g":49}]',69,0.7,18.1,0.2,0.9,10,0,false,false,'USDA 09132'),
('Kiwi','kiwi','fruta','[{"u":"unidad","g":69}]',61,1.1,14.7,0.5,3.0,34,0,false,false,'USDA 09148'),
('Guayaba','guayaba','fruta','[{"u":"unidad","g":55}]',68,2.6,14.3,1.0,5.4,18,0,false,false,'USDA 09139'),
-- Verduras
('Tomate','tomate','verdura','[{"u":"unidad","g":123}]',18,0.9,3.9,0.2,1.2,10,0,false,false,'USDA 11529'),
('Cebolla','cebolla','verdura','[{"u":"cda picada","g":10},{"u":"unidad","g":110}]',40,1.1,9.3,0.1,1.7,23,0,false,false,'USDA 11282'),
('Zanahoria','zanahoria','verdura','[{"u":"unidad","g":61},{"u":"taza rallada","g":110}]',41,0.9,9.6,0.2,2.8,33,0,false,false,'USDA 11124'),
('Brócoli cocido','brocoli','verdura','[{"u":"taza","g":156}]',35,2.4,7.2,0.4,3.3,40,0,false,false,'USDA 11091'),
('Espinaca cruda','espinaca','verdura','[{"u":"taza","g":30}]',23,2.9,3.6,0.4,2.2,99,0,false,false,'USDA 11457'),
('Lechuga romana','lechuga','verdura','[{"u":"taza","g":47}]',17,1.2,3.3,0.3,2.1,33,0,false,false,'USDA 11251'),
('Pepino','pepino','verdura','[{"u":"taza en rodajas","g":104}]',15,0.7,3.6,0.1,0.5,16,0,false,false,'USDA 11205'),
-- Lácteos (Canadá fortifica leche con vit D)
('Leche 2%','leche','lacteo','[{"u":"taza","g":250}]',50,3.3,4.8,2.0,0,120,40,true,false,'USDA 01079; vit D por fortificación canadiense'),
('Leche sin lactosa 2%','leche sin lactosa','lacteo','[{"u":"taza","g":250}]',50,3.3,4.8,2.0,0,120,40,false,false,'USDA 01079; vit D por fortificación canadiense'),
('Yogur griego natural 0%','yogur griego','lacteo','[{"u":"pote","g":175},{"u":"cda","g":15}]',59,10.2,3.6,0.4,0,110,0,true,false,'USDA 01256'),
('Queso fresco / campesino','queso campesino','lacteo','[{"u":"tajada","g":30}]',299,18.1,3.0,23.8,0,566,null,true,false,'USDA 01252'),
('Queso cheddar curado','queso cheddar','lacteo','[{"u":"tajada","g":20}]',403,24.9,1.3,33.1,0,721,null,false,false,'USDA 01009; curado: lactosa casi nula'),
-- Grasas, frutos secos, otros
('Aceite (oliva o vegetal)','aceite','grasa','[{"u":"cda","g":13.5},{"u":"cdta","g":4.5}]',884,0,0,100,0,1,0,false,false,'USDA 04053'),
('Mantequilla','mantequilla','grasa','[{"u":"cdta","g":5},{"u":"cda","g":14}]',717,0.9,0.1,81.1,0,24,60,false,false,'USDA 01001; lactosa traza'),
('Mantequilla de maní','mantequilla de mani','grasa','[{"u":"cda","g":16}]',588,25.1,20.0,50.4,6.0,43,0,false,false,'USDA 16098'),
('Almendras','almendras','fruto seco','[{"u":"puñado","g":28}]',579,21.2,21.6,49.9,12.5,269,0,false,false,'USDA 12061'),
('Azúcar','azucar','otro','[{"u":"cdta","g":4}]',387,0,100,0,0,1,0,false,false,'USDA 19335'),
('Café negro','cafe','bebida','[{"u":"pocillo","g":150},{"u":"taza","g":240}]',2,0.3,0,0,0,2,0,false,true,'USDA 14209')
on conflict (norm) do nothing;
