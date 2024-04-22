-- Make sure to put drug_mapper_helper.tsv in public.drug_mapper_helper

DROP TABLE IF EXISTS units;
CREATE TEMP TABLE units (
	unit_name text,
	unit_concept_id int,
	factor float DEFAULT 1.0
);
INSERT INTO units
VALUES
	('applic.', 45891000, 1),
	('drops', 9296, 1.0),
	('g', 8504, 1.0),
	('iu', 8718, 1.0),
	('mg', 8576, 1.0),
	('Miu', 8718, 1e-6),
	('ml', 8587, 1.0),
	('mmol', 9573, 1.0),
	('ng', 9600, 1.0),
	('pcs', NULL, 1.0), -- maybe actually 32912, bu see e.g. select * from drug_strength where drug_concept_id = 789721
	('spoons', 9416, 1.0),
	-- ('ug', 9655, 1.0),
	('ug', 8504, 1e-3), -- 1 microgram =  1/1000 mg
	('umol', 9667, 1.0);

with cte_source_drugs as (
	select
		concept.concept_id
		, dmh.drug_key
		, dmh.atc
		, dmh.numerator_value
		, dmh.numerator_unit
		, u1.unit_concept_id as numerator_unit_concept_id
		, u1.factor as quantity_factor
		, dmh.denominator_value
		, dmh.denominator_unit
		, u2.unit_concept_id as denominator_unit_concept_id
	from public.drug_mapping_helper as dmh
	left join units as u1
		on dmh.numerator_unit = u1.unit_name
	left join units as u2
		on dmh.denominator_unit = u2.unit_name
	inner join cdm.concept
		on concept.concept_code = dmh.atc
	where dmh.atc in ('C01CA03', 'C01CA04')
),
cte_clinical_drugs as (
	select *
	from cdm.concept
	where concept_class_id = 'Clinical Drug'
)
select
	distinct *
from cte_source_drugs as sd
inner join cdm.concept_relationship as cr
 	on cr.concept_id_1 = sd.concept_id
	and relationship_id = 'ATC - RxNorm pr lat'
inner join cdm.concept_ancestor as ca
	on ca.ancestor_concept_id = cr.concept_id_2
inner join cte_clinical_drugs as cd
	on cd.concept_id = ca.descendant_concept_id
inner join cdm.drug_strength as ds
	on ds.drug_concept_id = cd.concept_id
	and sd.numerator_unit_concept_id = ds.numerator_unit_concept_id
	and sd.denominator_unit_concept_id = ds.denominator_unit_concept_id





