extends Node3D

var car: CharacterBody3D
var plane: Node3D
var camera: Camera3D
var label: Label
var bullets: Array[Node3D] = []
var rng := RandomNumberGenerator.new()
var gear := 1
var speed := 0.0
const MAX_SPEED = [0.0, 7.0, 12.0, 18.0, 25.0, 34.0]
const FORCE = [0.0, 15.0, 13.0, 11.0, 9.0, 7.0]

func mat(c: Color):
	var m=StandardMaterial3D.new()
	m.albedo_color=c
	return m

func box(parent,pos,size,color):
	var n=MeshInstance3D.new()
	var m=BoxMesh.new()
	m.size=size
	n.mesh=m
	n.position=pos
	n.material_override=mat(color)
	parent.add_child(n)
	return n

func make_house(pos):
	var h=Node3D.new()
	h.position=pos
	add_child(h)
	box(h,Vector3(0,2,0),Vector3(6,4,5),Color("#b8a88f"))
	box(h,Vector3(0,4.5,0),Vector3(6.5,1.2,5.5),Color("#5b5048"))
	box(h,Vector3(0,1.7,2.55),Vector3(1,1.8,.12),Color("#49382e"))

func make_tree(pos):
	var t=Node3D.new()
	t.position=pos
	add_child(t)
	box(t,Vector3(0,1,0),Vector3(.35,2,.35),Color("#59483a"))
	var c=MeshInstance3D.new()
	var s=SphereMesh.new()
	s.radius=1.05
	s.height=2
	c.mesh=s
	c.position=Vector3(0,2.4,0)
	c.material_override=mat(Color("#254631"))
	t.add_child(c)

func make_plane():
	plane=Node3D.new()
	plane.position=Vector3(-10,25,4)
	add_child(plane)
	box(plane,Vector3.ZERO,Vector3(4.4,.65,1.05),Color("#465440"))
	box(plane,Vector3(0,0,-1.5),Vector3(.5,.18,3.1),Color("#53604a"))
	box(plane,Vector3(0,0,1.5),Vector3(.5,.18,3.1),Color("#53604a"))
	box(plane,Vector3(-1.6,.1,0),Vector3(1.1,.35,.7),Color("#263027"))

func make_car():
	car=CharacterBody3D.new()
	car.position=Vector3(-48,.8,0)
	add_child(car)
	box(car,Vector3.ZERO,Vector3(3.8,1,1.8),Color("#777263"))
	box(car,Vector3(-.25,.75,0),Vector3(2.4,.65,1.55),Color("#817d6d"))
	box(car,Vector3(.85,.9,0),Vector3(.55,.65,1.35),Color("#34352f"))
	for x in [-1.35,1.35]:
		var w=MeshInstance3D.new()
		var c=CylinderMesh.new()
		c.top_radius=.48
		c.bottom_radius=.48
		c.height=.28
		w.mesh=c
		w.rotation_degrees=Vector3(90,0,0)
		w.position=Vector3(x,-.55,0)
		w.material_override=mat(Color("#252525"))
		car.add_child(w)

func bullet(pos,color):
	var b=MeshInstance3D.new()
	var s=SphereMesh.new()
	s.radius=.15
	s.height=.3
	b.mesh=s
	b.material_override=mat(color)
	b.global_position=pos
	add_child(b)
	bullets.append(b)

func _ready():
	rng.randomize()
	var env=WorldEnvironment.new()
	var e=Environment.new()
	e.background_mode=Environment.BG_COLOR
	e.background_color=Color("#9eafbd")
	e.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color=Color("#b9c8d0")
	e.ambient_light_energy=.85
	env.environment=e
	add_child(env)

	var sun=DirectionalLight3D.new()
	sun.rotation_degrees=Vector3(-48,-25,0)
	sun.light_energy=1.15
	add_child(sun)

	box(self,Vector3(0,-.7,0),Vector3(180,1,180),Color("#d9d7cc"))
	box(self,Vector3(0,-.15,0),Vector3(150,.15,7),Color("#3e4142"))
	box(self,Vector3(20,-.13,14),Vector3(65,.12,4.5),Color("#806246"))

	for p in [Vector3(-55,13,-35),Vector3(48,18,-40),Vector3(-55,12,48),Vector3(58,16,42)]:
		var m=MeshInstance3D.new()
		var s=SphereMesh.new()
		s.radius=18
		s.height=34
		m.mesh=s
		m.position=p
		m.scale=Vector3(1.65,1,1.25)
		m.material_override=mat(Color("#edf2f4"))
		add_child(m)

	for p in [Vector3(-26,0,-11),Vector3(-7,0,-12),Vector3(14,0,-12),Vector3(34,0,-11),Vector3(-20,0,12),Vector3(2,0,12),Vector3(25,0,12)]:
		make_house(p)
	for p in [Vector3(-40,0,-17),Vector3(-14,0,-18),Vector3(8,0,-18),Vector3(30,0,-18),Vector3(-35,0,20),Vector3(-5,0,21),Vector3(18,0,21),Vector3(43,0,17)]:
		make_tree(p)

	make_car()
	make_plane()

	camera=Camera3D.new()
	camera.position=Vector3(-42,10,18)
	add_child(camera)
	camera.current=true

	label=Label.new()
	label.position=Vector2(24,24)
	label.add_theme_font_size_override("font_size",21)
	add_child(label)

func _physics_process(delta):
	if not car or not plane:
		return

	for g in range(1,6):
		if Input.is_key_pressed(KEY_1+g-1):
			gear=g

	var throttle=Input.get_axis("back","forward")
	var max_speed=MAX_SPEED[gear]
	if throttle>0:
		speed=move_toward(speed,max_speed*throttle,FORCE[gear]*delta)
	elif throttle<0:
		speed=move_toward(speed,-max_speed*.35,FORCE[gear]*.8*delta)
	else:
		speed=move_toward(speed,0,3*delta)

	car.rotate_y(Input.get_axis("left","right")*1.25*delta)
	car.velocity=-car.transform.basis.z*speed
	car.move_and_slide()

	plane.global_position=plane.global_position.lerp(car.global_position+Vector3(0,25,5),1.8*delta)
	plane.look_at(car.global_position,Vector3.UP)

	if rng.randf()<.012:
		bullet(plane.global_position,Color("#e34b35"))

	for b in bullets.duplicate():
		if not is_instance_valid(b):
			bullets.erase(b)
			continue
		var d=(car.global_position-b.global_position).normalized()
		b.global_position+=d*22*delta
		if b.global_position.distance_to(car.global_position)<1.2:
			b.queue_free()
			bullets.erase(b)

	if Input.is_action_just_pressed("fire"):
		bullet(car.global_position+Vector3(0,1,0),Color("#e8b23f"))

	camera.global_position=camera.global_position.lerp(car.global_position+Vector3(-17,9,17),3.2*delta)
	camera.look_at(car.global_position+Vector3(0,1,0),Vector3.UP)
	label.text="Kübelwagen | دنده %d | سرعت %.1f | W گاز  S ترمز  A/D فرمان | هواپیمای دشمن" % [gear,abs(speed)]
